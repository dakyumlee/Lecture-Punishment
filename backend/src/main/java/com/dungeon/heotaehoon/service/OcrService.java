package com.dungeon.heotaehoon.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
            questions = mergeDuplicateQuestions(questions);
            log.info("Parsed {} questions after merging", questions.size());
            
        } catch (Exception e) {
            log.error("OCR extraction failed", e);
            throw e;
        }
        
        return questions;
    }

    private List<QuestionData> parseQuestions(String text) {
        List<QuestionData> questions = new ArrayList<>();
        
        Pattern questionPattern = Pattern.compile(
            "(\\d+)\\s*\\.\\s*(.+?)(?=\\n\\s*\\d+\\s*\\.|$)",
            Pattern.DOTALL
        );
        
        Matcher matcher = questionPattern.matcher(text);
        
        while (matcher.find()) {
            int questionNumber = Integer.parseInt(matcher.group(1));
            String questionContent = matcher.group(2).trim();
            
            QuestionData question = new QuestionData();
            question.setQuestionNumber(questionNumber);
            
            if (isMultipleChoice(questionContent)) {
                parseMultipleChoice(question, questionContent);
            } else {
                question.setQuestionType("subjective");
                question.setQuestionText(questionContent);
            }
            
            questions.add(question);
        }
        
        return questions;
    }

    private List<QuestionData> mergeDuplicateQuestions(List<QuestionData> questions) {
        Map<Integer, QuestionData> mergedMap = new HashMap<>();
        
        for (QuestionData question : questions) {
            Integer qNum = question.getQuestionNumber();
            
            if (mergedMap.containsKey(qNum)) {
                QuestionData existing = mergedMap.get(qNum);
                
                if (existing.getQuestionType().equals("subjective") && 
                    isMultipleChoice(question.getQuestionText())) {
                    existing.setQuestionType("multiple_choice");
                    parseMultipleChoice(existing, question.getQuestionText());
                } else if (question.getQuestionType().equals("multiple_choice")) {
                    existing.setQuestionType("multiple_choice");
                    if (existing.getOptionA() == null) existing.setOptionA(question.getOptionA());
                    if (existing.getOptionB() == null) existing.setOptionB(question.getOptionB());
                    if (existing.getOptionC() == null) existing.setOptionC(question.getOptionC());
                    if (existing.getOptionD() == null) existing.setOptionD(question.getOptionD());
                } else {
                    existing.setQuestionText(existing.getQuestionText() + " " + question.getQuestionText());
                }
            } else {
                mergedMap.put(qNum, question);
            }
        }
        
        return new ArrayList<>(mergedMap.values());
    }

    private boolean isMultipleChoice(String content) {
        String[] circleNumbers = {"①", "②", "③", "④", "⑤"};
        int circleCount = 0;
        for (String circle : circleNumbers) {
            if (content.contains(circle)) circleCount++;
        }
        if (circleCount >= 4) return true;
        
        Pattern bracketPattern = Pattern.compile("\\d+\\)\\s+[^\\d)]{2,}");
        Matcher bracketMatcher = bracketPattern.matcher(content);
        int bracketCount = 0;
        while (bracketMatcher.find()) {
            bracketCount++;
        }
        if (bracketCount >= 4) return true;
        
        Pattern parenthesisPattern = Pattern.compile("\\(\\d+\\)\\s+[^()]{2,}");
        Matcher parenthesisMatcher = parenthesisPattern.matcher(content);
        int parenthesisCount = 0;
        while (parenthesisMatcher.find()) {
            parenthesisCount++;
        }
        if (parenthesisCount >= 4) return true;
        
        return false;
    }

    private void parseMultipleChoice(QuestionData question, String content) {
        question.setQuestionType("multiple_choice");
        
        String[] circleNumbers = {"①", "②", "③", "④"};
        String firstMarker = null;
        for (String circle : circleNumbers) {
            if (content.contains(circle)) {
                firstMarker = circle;
                break;
            }
        }
        
        if (firstMarker == null) {
            Pattern bracketPattern = Pattern.compile("\\d+\\)");
            Matcher bracketMatcher = bracketPattern.matcher(content);
            if (bracketMatcher.find()) {
                firstMarker = bracketMatcher.group();
            }
        }
        
        if (firstMarker == null) {
            Pattern parenthesisPattern = Pattern.compile("\\(\\d+\\)");
            Matcher parenthesisMatcher = parenthesisPattern.matcher(content);
            if (parenthesisMatcher.find()) {
                firstMarker = parenthesisMatcher.group();
            }
        }
        
        if (firstMarker != null) {
            String[] parts = content.split(Pattern.quote(firstMarker), 2);
            if (parts.length > 0 && question.getQuestionText() == null) {
                question.setQuestionText(parts[0].trim());
            }
            
            if (parts.length > 1) {
                String optionsText = firstMarker + parts[1];
                parseOptions(question, optionsText);
            }
        } else {
            if (question.getQuestionText() == null) {
                question.setQuestionText(content);
            }
        }
    }

    private void parseOptions(QuestionData question, String optionsText) {
        Pattern circlePattern = Pattern.compile("([①②③④⑤])\\s*([^①②③④⑤]+?)(?=[①②③④⑤]|$)", Pattern.DOTALL);
        Pattern bracketPattern = Pattern.compile("(\\d+)\\)\\s*([^\\d)]+?)(?=\\d+\\)|$)", Pattern.DOTALL);
        Pattern parenthesisPattern = Pattern.compile("\\((\\d+)\\)\\s*([^()]+?)(?=\\(\\d+\\)|$)", Pattern.DOTALL);
        
        Matcher matcher = circlePattern.matcher(optionsText);
        if (!matcher.find()) {
            matcher = bracketPattern.matcher(optionsText);
            if (!matcher.find()) {
                matcher = parenthesisPattern.matcher(optionsText);
            }
        }
        
        matcher.reset();
        int optionIndex = 0;
        while (matcher.find() && optionIndex < 4) {
            String optionText = matcher.group(2).trim()
                .replaceAll("\\s+", " ")
                .trim();
            
            switch (optionIndex) {
                case 0: if (question.getOptionA() == null) question.setOptionA(optionText); break;
                case 1: if (question.getOptionB() == null) question.setOptionB(optionText); break;
                case 2: if (question.getOptionC() == null) question.setOptionC(optionText); break;
                case 3: if (question.getOptionD() == null) question.setOptionD(optionText); break;
            }
            optionIndex++;
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
