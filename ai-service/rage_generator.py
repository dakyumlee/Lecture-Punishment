import os
import openai
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

openai.api_key = os.getenv('OPENAI_API_KEY')

RAGE_PROMPTS = {
    'wrong_answer': "허태훈 강사의 스타일로 학생이 문제를 틀렸을 때 하는 날카롭고 독설적인 한마디를 생성해줘. 반말로, 30자 이내로.",
    'correct_answer': "허태훈 강사의 스타일로 학생이 문제를 맞췄을 때 하는 무뚝뚝하지만 인정하는 듯한 한마디를 생성해줘. 반말로, 20자 이내로.",
    'mental_break': "허태훈 강사의 스타일로 학생의 멘탈을 완전히 무너뜨리는 심리전 대사를 생성해줘. 반말로, 40자 이내로.",
    'combo_3': "허태훈 강사의 스타일로 학생이 3연속 정답을 맞췄을 때 놀라면서도 칭찬하는 한마디를 생성해줘. 반말로, 30자 이내로.",
}

@app.route('/api/ai/rage-dialogue', methods=['POST'])
def generate_rage_dialogue():
    data = request.json
    dialogue_type = data.get('dialogueType', 'wrong_answer')
    
    if dialogue_type not in RAGE_PROMPTS:
        return jsonify({'error': 'Invalid dialogue type'}), 400
    
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {
                    "role": "system",
                    "content": "너는 허태훈이라는 독설가 강사야. 학생들을 엄격하게 가르치지만 사실 그들의 성장을 바라는 마음이 있어."
                },
                {
                    "role": "user",
                    "content": RAGE_PROMPTS[dialogue_type]
                }
            ],
            temperature=0.9,
            max_tokens=100
        )
        
        dialogue = response.choices[0].message.content.strip()
        
        return jsonify({
            'dialogue': dialogue,
            'dialogueType': dialogue_type
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/tts', methods=['POST'])
def text_to_speech():
    data = request.json
    text = data.get('text', '')
    
    try:
        response = openai.Audio.create(
            model="tts-1",
            voice="onyx",
            input=text
        )
        
        return jsonify({
            'audioUrl': response.url
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
