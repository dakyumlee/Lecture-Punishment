package com.dungeon.heotaehoon.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
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
            List<String> pageImages = new ArrayList<>();
            
            log.info("PDF has {} pages", document.getNumberOfPages());
            
            for (int page = 0; page < document.getNumberOfPages(); page++) {
                try {
                    log.info("Processing page {}/{}", page + 1, document.getNumberOfPages());
                    
                    BufferedImage image = pdfRenderer.renderImageWithDPI(page, 600);
                    
                    String base64Image = imageToBase64(image);
                    pageImages.add(base64Image);
                    
                    String pageText = tesseract.doOCR(image);
                    fullText.append(pageText).append("\n");
                    
                    log.info("Page {} processed: {} chars", page + 1, pageText.length());
                } catch (Exception e) {
                    log.error("Failed to process page {}", page + 1, e);
                }
            }
            
            String extractedText = fullText.toString();
            log.info("Total extracted text length: {}", extractedText.length());
            log.debug("Extracted text: {}", extractedText);
            
            if (extractedText.length() > 0) {
                questions = parseQuestions(extractedText);
                
                if (!questions.isEmpty() && !pageImages.isEmpty()) {
                    questions.get(0).setImageData(pageImages.get(0));
                }
                
                log.info("Parsed {} questions", questions.size());
            } else {
                log.warn("No text extracted from PDF");
            }
            
        } catch (Exception e) {
            log.error("OCR extraction failed", e);
            throw new RuntimeException("OCR 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
        
        return questions;
    }

    private String imageToBase64(BufferedImage image) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "png", baos);
        byte[] imageBytes = baos.toByteArray();
        return Base64.getEncoder().encodeToString(imageBytes);
    }

    private List<QuestionData> parseQuestions(String text) {
        List<QuestionData> questions = new ArrayList<>();
        
        String cleanedText = text
            .replaceAll("(?s)자바&Springboot.*?(?=\\d+\\.)", "")
            .replaceAll("(?s)평가일시.*?(?=\\d+\\.)", "")
            .replaceAll("(?s)배점.*?(?=\\d+\\.)", "");
        
        Pattern questionPattern = Pattern.compile(
            "(\\d+)\\.\\s*(.+?)(?=(?:\\d+\\.|$))",
            Pattern.DOTALL
        );
        
        Matcher matcher = questionPattern.matcher(cleanedText);
        
        while (matcher.find()) {
            try {
                int questionNumber = Integer.parseInt(matcher.group(1).trim());
                String fullContent = matcher.group(2).trim();
                
                if (fullContent.length() < 10) {
                    continue;
                }
                
                QuestionData question = new QuestionData();
                question.setQuestionNumber(questionNumber);
                question.setPoints(10);
                question.setCorrectAnswer("1");
                
                log.info("Processing Q{}: {}", questionNumber, fullContent.substring(0, Math.min(100, fullContent.length())));
                
                if (fullContent.contains("1)") || fullContent.contains("①")) {
                    question.setQuestionType("multiple_choice");
                    
                    String questionText;
                    String optionsText;
                    
                    int optionStart = fullContent.indexOf("1)");
                    if (optionStart == -1) {
                        optionStart = fullContent.indexOf("①");
                    }
                    
                    if (optionStart > 0) {
                        questionText = fullContent.substring(0, optionStart).trim();
                        optionsText = fullContent.substring(optionStart).trim();
                        
                        question.setQuestionText(questionText);
                        
                        String[] options = new String[4];
                        
                        if (optionsText.contains("①")) {
                            Pattern circlePattern = Pattern.compile("①\\s*(.+?)\\s*②\\s*(.+?)\\s*③\\s*(.+?)\\s*④\\s*(.+?)(?=⑤|$)", Pattern.DOTALL);
                            Matcher circleMatcher = circlePattern.matcher(optionsText);
                            
                            if (circleMatcher.find()) {
                                options[0] = circleMatcher.group(1).trim().replaceAll("\\s+", " ");
                                options[1] = circleMatcher.group(2).trim().replaceAll("\\s+", " ");
                                options[2] = circleMatcher.group(3).trim().replaceAll("\\s+", " ");
                                options[3] = circleMatcher.group(4).trim().replaceAll("\\s+", " ");
                            }
                        } else {
                            Pattern numberPattern = Pattern.compile("(\\d+)\\)\\s*([^\\d)]+?)(?=\\d+\\)|$)", Pattern.DOTALL);
                            Matcher numberMatcher = numberPattern.matcher(optionsText);
                            
                            while (numberMatcher.find()) {
                                int optNum = Integer.parseInt(numberMatcher.group(1).trim());
                                String optText = numberMatcher.group(2).trim().replaceAll("\\s+", " ");
                                
                                if (optNum >= 1 && optNum <= 4) {
                                    options[optNum - 1] = optText;
                                }
                            }
                        }
                        
                        question.setOptionA(options[0] != null ? options[0] : "");
                        question.setOptionB(options[1] != null ? options[1] : "");
                        question.setOptionC(options[2] != null ? options[2] : "");
                        question.setOptionD(options[3] != null ? options[3] : "");
                        
                        log.info("Q{} - Options: A={}, B={}, C={}, D={}", 
                            questionNumber, 
                            options[0] != null ? options[0].substring(0, Math.min(20, options[0].length())) : "null",
                            options[1] != null ? options[1].substring(0, Math.min(20, options[1].length())) : "null",
                            options[2] != null ? options[2].substring(0, Math.min(20, options[2].length())) : "null",
                            options[3] != null ? options[3].substring(0, Math.min(20, options[3].length())) : "null");
                    } else {
                        question.setQuestionText(fullContent);
                    }
                } else {
                    question.setQuestionType("subjective");
                    question.setQuestionText(fullContent);
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
        private String imageData;

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
        public String getImageData() { return imageData; }
        public void setImageData(String imageData) { this.imageData = imageData; }
    }
}
