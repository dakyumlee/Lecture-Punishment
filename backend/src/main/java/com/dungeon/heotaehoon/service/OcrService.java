package com.dungeon.heotaehoon.service;

import com.dungeon.heotaehoon.dto.QuestionData;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class OcrService {

    private String getTessdataPath() {
        String envPath = System.getenv("TESSDATA_PREFIX");
        if (envPath != null && !envPath.isEmpty()) {
            return envPath;
        }
        return "/usr/share/tesseract-ocr/5/tessdata";
    }

    public List<QuestionData> extractQuestionsFromPdf(MultipartFile file) throws IOException, TesseractException {
        List<QuestionData> questions = new ArrayList<>();
        
        try (PDDocument document = Loader.loadPDF(file.getBytes())) {
            PDFRenderer renderer = new PDFRenderer(document);
            
            for (int pageIndex = 0; pageIndex < document.getNumberOfPages(); pageIndex++) {
                BufferedImage image = renderer.renderImageWithDPI(pageIndex, 300);
                
                Tesseract tesseract = new Tesseract();
                tesseract.setDatapath(getTessdataPath());
                tesseract.setLanguage("kor+eng");
                
                String text = tesseract.doOCR(image);
                questions.addAll(parseQuestionsFromText(text));
            }
        }
        
        return questions;
    }

    public String extractTextFromPdf(MultipartFile file) throws IOException, TesseractException {
        StringBuilder fullText = new StringBuilder();
        
        try (PDDocument document = Loader.loadPDF(file.getBytes())) {
            PDFRenderer renderer = new PDFRenderer(document);
            
            for (int pageIndex = 0; pageIndex < document.getNumberOfPages(); pageIndex++) {
                BufferedImage image = renderer.renderImageWithDPI(pageIndex, 300);
                
                Tesseract tesseract = new Tesseract();
                tesseract.setDatapath(getTessdataPath());
                tesseract.setLanguage("kor+eng");
                
                String pageText = tesseract.doOCR(image);
                fullText.append(pageText).append("\n\n");
            }
        }
        
        return fullText.toString();
    }

    private List<QuestionData> parseQuestionsFromText(String text) {
        List<QuestionData> questions = new ArrayList<>();
        Pattern pattern = Pattern.compile("(\\d+)\\.\\s*([^\\n]+)");
        Matcher matcher = pattern.matcher(text);
        
        while (matcher.find()) {
            QuestionData question = new QuestionData();
            question.setQuestionNumber(Integer.parseInt(matcher.group(1)));
            question.setQuestionText(matcher.group(2).trim());
            questions.add(question);
        }
        
        return questions;
    }
}
