package com.dungeon.heotaehoon.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFPicture;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class OcrService {

    public List<QuestionData> extractQuestionsFromPdf(MultipartFile file) throws IOException, TesseractException {
        List<QuestionData> questions = new ArrayList<>();
        
        log.info("Starting OCR extraction for file: {}", file.getOriginalFilename());
        
        try (InputStream inputStream = file.getInputStream();
            PDDocument document = PDDocument.load(inputStream)) {
            
            PDFRenderer pdfRenderer = new PDFRenderer(document);
            Tesseract tesseract = new Tesseract();
            
            tesseract.setDatapath("/usr/share/tessdata");
            tesseract.setLanguage("kor+eng");
            
            StringBuilder fullText = new StringBuilder();
            
            for (int page = 0; page < document.getNumberOfPages(); page++) {
                try {
                    BufferedImage image = pdfRenderer.renderImageWithDPI(page, 300);
                    String pageText = tesseract.doOCR(image);
                    fullText.append(pageText).append("\n");
                } catch (Exception e) {
                    log.error("Failed to process page {}", page + 1, e);
                }
            }
            
            String extractedText = fullText.toString();
            questions = parseQuestions(extractedText);
            
        } catch (Exception e) {
            log.error("OCR extraction failed", e);
            throw new RuntimeException("OCR 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
        
        return questions;
    }

    public List<QuestionData> extractQuestionsFromDocx(MultipartFile file) throws IOException {
        List<QuestionData> questions = new ArrayList<>();
        
        log.info("Starting DOCX extraction for file: {}", file.getOriginalFilename());
        
        try (InputStream inputStream = file.getInputStream();
            XWPFDocument document = new XWPFDocument(inputStream)) {
            
            StringBuilder fullText = new StringBuilder();
            Tesseract tesseract = new Tesseract();
            tesseract.setDatapath("/usr/share/tessdata");
            tesseract.setLanguage("kor+eng");
            
            for (XWPFParagraph paragraph : document.getParagraphs()) {
                String text = paragraph.getText();
                if (text != null && !text.trim().isEmpty()) {
                    fullText.append(text).append("\n");
                }
                
                for (XWPFRun run : paragraph.getRuns()) {
                    List<XWPFPicture> pictures = run.getEmbeddedPictures();
                    for (XWPFPicture picture : pictures) {
                        try {
                            byte[] imageData = picture.getPictureData().getData();
                            BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageData));
                            
                            if (image != null) {
                                String imageText = tesseract.doOCR(image);
                                if (imageText != null && !imageText.trim().isEmpty()) {
                                    fullText.append("\n").append(imageText).append("\n");
                                    log.info("Extracted text from image: {} chars", imageText.length());
                                }
                            }
                        } catch (Exception e) {
                            log.warn("Failed to process embedded image", e);
                        }
                    }
                }
            }
            
            String extractedText = fullText.toString();
            log.info("Total extracted text length: {}", extractedText.length());
            
            questions = parseQuestions(extractedText);
            
        } catch (Exception e) {
            log.error("DOCX extraction failed", e);
            throw new RuntimeException("DOCX 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
        
        return questions;
    }

    private List<QuestionData> parseQuestions(String text) {
        List<QuestionData> questions = new ArrayList<>();
        
        Pattern questionPattern = Pattern.compile(
            "(\\d+)\\.\\s*(.+?)(?=(?:\\d+\\.|$))",
            Pattern.DOTALL
        );
        
        Matcher matcher = questionPattern.matcher(text);
        
        while (matcher.find()) {
            try {
                int questionNumber = Integer.parseInt(matcher.group(1).trim());
                String fullContent = matcher.group(2).trim();
                
                if (fullContent.length() < 10) continue;
                
                QuestionData question = new QuestionData();
                question.setQuestionNumber(questionNumber);
                question.setQuestionType("multiple_choice");
                question.setPoints(10);
                question.setCorrectAnswer("A");
                
                if (fullContent.contains("1)") || fullContent.contains("①")) {
                    int optionStart = fullContent.indexOf("1)");
                    if (optionStart == -1) optionStart = fullContent.indexOf("①");
                    
                    if (optionStart > 0) {
                        String questionText = fullContent.substring(0, optionStart).trim();
                        String optionsText = fullContent.substring(optionStart).trim();
                        
                        question.setQuestionText(questionText);
                        
                        String[] options = new String[4];
                        Pattern numberPattern = Pattern.compile("(\\d+)\\)\\s*([^\\d)]+?)(?=\\d+\\)|$)", Pattern.DOTALL);
                        Matcher numberMatcher = numberPattern.matcher(optionsText);
                        
                        while (numberMatcher.find()) {
                            int optNum = Integer.parseInt(numberMatcher.group(1).trim());
                            String optText = numberMatcher.group(2).trim();
                            
                            if (optNum >= 1 && optNum <= 4) {
                                options[optNum - 1] = optText;
                            }
                        }
                        
                        question.setOptionA(options[0] != null ? options[0] : "");
                        question.setOptionB(options[1] != null ? options[1] : "");
                        question.setOptionC(options[2] != null ? options[2] : "");
                        question.setOptionD(options[3] != null ? options[3] : "");
                    }
                } else {
                    question.setQuestionText(fullContent);
                    question.setQuestionType("subjective");
                }
                
                questions.add(question);
                
            } catch (Exception e) {
                log.warn("Failed to parse question", e);
            }
        }
        
        return questions;
    }

    public static class QuestionData {
        private Integer questionNumber;
        private String questionType;
        private String questionText;
        private String optionA;
        private String optionB;
        private String optionC;
        private String optionD;
        private String correctAnswer;
        private Integer points;

        public Integer getQuestionNumber() { return questionNumber; }
        public void setQuestionNumber(Integer questionNumber) { this.questionNumber = questionNumber; }
        public String getQuestionType() { return questionType; }
        public void setQuestionType(String questionType) { this.questionType = questionType; }
        public String getQuestionText() { return questionText; }
        public void setQuestionText(String questionText) { this.questionText = questionText; }
        public String getOptionA() { return optionA; }
        public void setOptionA(String optionA) { this.optionA = optionA; }
        public String getOptionB() { return optionB; }
        public void setOptionB(String optionB) { this.optionB = optionB; }
        public String getOptionC() { return optionC; }
        public void setOptionC(String optionC) { this.optionC = optionC; }
        public String getOptionD() { return optionD; }
        public void setOptionD(String optionD) { this.optionD = optionD; }
        public String getCorrectAnswer() { return correctAnswer; }
        public void setCorrectAnswer(String correctAnswer) { this.correctAnswer = correctAnswer; }
        public Integer getPoints() { return points; }
        public void setPoints(Integer points) { this.points = points; }
    }
}
