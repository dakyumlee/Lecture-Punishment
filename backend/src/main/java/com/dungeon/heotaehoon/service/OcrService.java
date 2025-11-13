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
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
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
            
            tesseract.setLanguage("kor+eng");
            
            StringBuilder fullText = new StringBuilder();
            
            log.info("PDF has {} pages", document.getNumberOfPages());
            
            for (int page = 0; page < document.getNumberOfPages(); page++) {
                log.info("Processing page {}", page + 1);
                BufferedImage image = pdfRenderer.renderImageWithDPI(page, 300);
                String pageText = tesseract.doOCR(image);
                fullText.append(pageText).append("\n");
            }
            
            log.info("Extracted text length: {}", fullText.length());
            questions = parseQuestions(fullText.toString());
            log.info("Parsed {} questions", questions.size());
            
        } catch (Exception e) {
            log.error("OCR extraction failed", e);
            throw e;
        }
        
        return questions;
    }

    private List<QuestionData> parseQuestions(String text) {
        List<QuestionData> questions = new ArrayList<>();
        
        Pattern questionPattern = Pattern.compile(
            "(\\d+)\\s*\\.\\s*(.+?)(?=\\n\\s*①|\\n\\s*\\d+\\s*\\.|$)",
            Pattern.DOTALL
        );
        
        Matcher matcher = questionPattern.matcher(text);
        
        while (matcher.find()) {
            int questionNumber = Integer.parseInt(matcher.group(1));
            String questionContent = matcher.group(2).trim();
            
            QuestionData question = new QuestionData();
            question.setQuestionNumber(questionNumber);
            
            if (questionContent.contains("①")) {
                parseMultipleChoice(question, questionContent);
            } else {
                question.setQuestionType("subjective");
                question.setQuestionText(questionContent);
            }
            
            questions.add(question);
        }
        
        return questions;
    }

    private void parseMultipleChoice(QuestionData question, String content) {
        question.setQuestionType("multiple_choice");
        
        String[] parts = content.split("①");
        if (parts.length > 0) {
            question.setQuestionText(parts[0].trim());
        }
        
        if (parts.length > 1) {
            String optionsText = "①" + parts[1];
            
            Pattern optionPattern = Pattern.compile("([①②③④⑤])\\s*([^①②③④⑤]+)");
            Matcher optionMatcher = optionPattern.matcher(optionsText);
            
            int optionIndex = 0;
            while (optionMatcher.find() && optionIndex < 4) {
                String optionText = optionMatcher.group(2).trim();
                switch (optionIndex) {
                    case 0: question.setOptionA(optionText); break;
                    case 1: question.setOptionB(optionText); break;
                    case 2: question.setOptionC(optionText); break;
                    case 3: question.setOptionD(optionText); break;
                }
                optionIndex++;
            }
        }
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
