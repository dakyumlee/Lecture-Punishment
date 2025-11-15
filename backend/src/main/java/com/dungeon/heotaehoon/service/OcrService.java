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
            log.info("Tesseract datapath set to: /usr/share/tessdata");
            
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
                    
                    String cleanedText = pageText
                        .replaceAll("<[^>]+>", "")
                        .replaceAll("\\(pre\\)", "")
                        .replaceAll("\\{[^}]+\\}", "")
                        .replaceAll("\\s+", " ")
                        .trim();
                    
                    fullText.append(cleanedText).append("\n\n");
                    
                    log.info("Page {} processed: {} chars -> {} chars cleaned", 
                        page + 1, pageText.length(), cleanedText.length());
                } catch (Exception e) {
                    log.error("Failed to process page {}", page + 1, e);
                }
            }
            
            log.info("Total extracted text length: {}", fullText.length());
            
            if (fullText.length() > 0) {
                questions = parseQuestions(fullText.toString());
                
                for (int i = 0; i < questions.size() && i < pageImages.size(); i++) {
                    questions.get(i).setImageData(pageImages.get(i));
                }
                
                log.info("Parsed {} questions with images", questions.size());
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
        
        Pattern questionPattern = Pattern.compile(
            "(\\d+)\\s*번?[.)]?\\s+(.+?)(?=\\d+\\s*번?[.)]|$)",
            Pattern.DOTALL
        );
        
        Matcher matcher = questionPattern.matcher(text);
        
        while (matcher.find()) {
            try {
                int questionNumber = Integer.parseInt(matcher.group(1).trim());
                String questionContent = matcher.group(2).trim();
                
                if (questionContent.length() < 5) {
                    continue;
                }
                
                QuestionData question = new QuestionData();
                question.setQuestionNumber(questionNumber);
                question.setPoints(10);
                question.setCorrectAnswer("1");
                
                if (hasOptions(questionContent)) {
                    question.setQuestionType("multiple_choice");
                    parseQuestionWithOptions(question, questionContent);
                } else {
                    question.setQuestionType("subjective");
                    question.setQuestionText(questionContent);
                }
                
                questions.add(question);
                log.info("Parsed question {}: {} chars", questionNumber, questionContent.length());
            } catch (Exception e) {
                log.warn("Failed to parse question", e);
            }
        }
        
        return questions;
    }

    private boolean hasOptions(String content) {
        return content.matches(".*[①②③④⑤].*") || 
               content.matches(".*\\d+\\).*\\d+\\).*") ||
               content.matches(".*\\(\\d+\\).*\\(\\d+\\).*");
    }

    private void parseQuestionWithOptions(QuestionData question, String content) {
        String questionText = content;
        String[] options = new String[4];
        
        Pattern circlePattern = Pattern.compile("(.*?)①\\s*([^②③④⑤]+?)\\s*②\\s*([^②③④⑤]+?)\\s*③\\s*([^②③④⑤]+?)\\s*④\\s*([^②③④⑤]+?).*", Pattern.DOTALL);
        Matcher circleMatcher = circlePattern.matcher(content);
        
        if (circleMatcher.find()) {
            questionText = circleMatcher.group(1).trim();
            options[0] = circleMatcher.group(2).trim();
            options[1] = circleMatcher.group(3).trim();
            options[2] = circleMatcher.group(4).trim();
            options[3] = circleMatcher.group(5).trim();
        } else {
            Pattern numberPattern = Pattern.compile("(.*?)1\\)\\s*([^2)]+?)\\s*2\\)\\s*([^3)]+?)\\s*3\\)\\s*([^4)]+?)\\s*4\\)\\s*([^5)]+?).*", Pattern.DOTALL);
            Matcher numberMatcher = numberPattern.matcher(content);
            
            if (numberMatcher.find()) {
                questionText = numberMatcher.group(1).trim();
                options[0] = numberMatcher.group(2).trim();
                options[1] = numberMatcher.group(3).trim();
                options[2] = numberMatcher.group(4).trim();
                options[3] = numberMatcher.group(5).trim();
            } else {
                Pattern parenPattern = Pattern.compile("(.*?)\\(1\\)\\s*([^()]+?)\\s*\\(2\\)\\s*([^()]+?)\\s*\\(3\\)\\s*([^()]+?)\\s*\\(4\\)\\s*([^()]+?).*", Pattern.DOTALL);
                Matcher parenMatcher = parenPattern.matcher(content);
                
                if (parenMatcher.find()) {
                    questionText = parenMatcher.group(1).trim();
                    options[0] = parenMatcher.group(2).trim();
                    options[1] = parenMatcher.group(3).trim();
                    options[2] = parenMatcher.group(4).trim();
                    options[3] = parenMatcher.group(5).trim();
                }
            }
        }
        
        question.setQuestionText(questionText);
        question.setOptionA(options[0] != null ? options[0].replaceAll("\\s+", " ") : "");
        question.setOptionB(options[1] != null ? options[1].replaceAll("\\s+", " ") : "");
        question.setOptionC(options[2] != null ? options[2].replaceAll("\\s+", " ") : "");
        question.setOptionD(options[3] != null ? options[3].replaceAll("\\s+", " ") : "");
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
