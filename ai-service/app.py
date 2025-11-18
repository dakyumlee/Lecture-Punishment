from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI
import os
import random

app = Flask(__name__)
CORS(app)

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY', 'dummy-key'))

LEGENDARY_RAGE_QUOTES = [
    "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ",
    "목졸라뿐다",
    "니대가리로 이해가 가긴 하겠니",
    "야 그건 기본이잖아!",
    "이게 안 되면 앞으로 어쩌려고?",
    "아니 그걸 틀려? 진짜?",
    "다시 한 번 생각해봐... 아니다, 생각 자체를 안 하는구나",
    "이 정도도 못 풀면 뭐하러 왔어?",
    "복습은 개뿔, 예습도 안 했지?",
    "너 진짜 수업 들었어? 잤지?"
]

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy", "instructor": "허태훈"})

@app.route('/api/ai/rage-dialogue', methods=['POST'])
def generate_rage_dialogue():
    data = request.json
    dialogue_type = data.get('dialogueType', 'wrong_answer')
    student_name = data.get('studentName', '학생')
    question = data.get('question', '')
    wrong_answer = data.get('wrongAnswer', '')
    correct_answer = data.get('correctAnswer', '')
    combo = data.get('combo', 0)
    
    prompts = {
        'wrong_answer': f"""너는 전설의 독설 강사 '허태훈'이야. 

학생: {student_name}
문제: {question}
학생이 고른 답: {wrong_answer}
정답: {correct_answer}

학생이 틀렸어. 허태훈 특유의 날카롭고 독설적인 한마디로 멘탈을 흔들어. 
반말, 25자 이내, 한 문장만. 

예시:
- "아 진짜? 그걸 틀려?"
- "복습은 개뿔, 예습도 안 했지?"
- "이게 안 풀리면 접어"

한 문장만 출력:""",

        'correct_answer': """허태훈 강사가 학생이 문제를 맞췄을 때 하는 무뚝뚝한 반응을 만들어.

반말, 15자 이내, 칭찬 같지 않은 칭찬.

예시:
- "음... 운이 좋았네"
- "이 정도는 해야지"
- "겨우 맞췄구나"

한 문장만:""",

        'mental_break': f"""허태훈이 학생 '{student_name}'의 멘탈을 완전히 무너뜨리는 심리전 대사.

반말, 40자 이내, 철학적이면서 잔인하게.

예시:
- "아니야, 네가 못한 게 아니라 세상이 널 버린 거야"
- "포기하는 것도 용기야... 근데 넌 그럴 용기도 없지?"
- "너도 알잖아... 넌 안 될 거란 거"

한 문장만:""",

        'combo_3': f"""허태훈이 학생의 {combo}연속 정답에 놀라면서도 인정하는 대사.

반말, 25자 이내, 놀람과 약간의 칭찬.

예시:
- "오, 이건 좀 하는데?"
- "드디어 제대로 하네"
- "복습 좀 했구나?"

한 문장만:""",

        'combo_broken': f"""허태훈이 {combo}콤보가 끊겼을 때 비꼬는 대사.

반말, 30자 이내, 안타까운 척하면서 비꼼.

예시:
- "ㅋㅋ 아깝긴 뭐가 아까워"
- "거기까지였구나"
- "역시 너답네"

한 문장만:"""
    }
    
    fallbacks = {
        'wrong_answer': LEGENDARY_RAGE_QUOTES,
        'correct_answer': ["음... 운이 좋았네", "겨우 맞췄구나", "이 정도는 해야지"],
        'mental_break': ["아니야, 네가 못한 게 아니라 세상이 널 버린 거야", "너도 알잖아... 넌 안 될 거란 거"],
        'combo_3': ["오, 이건 좀 하는데?", "드디어 제대로 하네", "복습 좀 했구나?"],
        'combo_broken': ["ㅋㅋ 아깝긴 뭐가 아까워", "거기까지였구나", "역시 너답네"]
    }
    
    if dialogue_type not in prompts:
        return jsonify({'error': 'Invalid dialogue type'}), 400
    
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": """너는 '허태훈', 전설의 독설 강사야. 
                    
특징:
- 날카롭고 직설적
- 학생 멘탈 흔드는 게 특기
- 근데 사실 학생들 성장 바람
- 반말 사용
- 짧고 강렬하게
- 이모티콘 안 씀
- "ㅋㅋ", "ㅎㅎ" 같은 건 가끔 비꼴 때만"""
                },
                {
                    "role": "user",
                    "content": prompts[dialogue_type]
                }
            ],
            temperature=1.0,
            max_tokens=80
        )
        
        dialogue = response.choices[0].message.content.strip()
        dialogue = dialogue.replace('"', '').replace("'", "")
        
        return jsonify({
            'dialogue': dialogue,
            'dialogueType': dialogue_type,
            'isAI': True
        })
    
    except Exception as e:
        print(f"OpenAI Error: {e}")
        return jsonify({
            'dialogue': random.choice(fallbacks.get(dialogue_type, LEGENDARY_RAGE_QUOTES)),
            'dialogueType': dialogue_type,
            'isAI': False
        })

@app.route('/api/ai/generate-quizzes', methods=['POST'])
def generate_quizzes():
    data = request.json
    topic = data.get('topic')
    difficulty = data.get('difficulty', 3)
    count = data.get('count', 20)
    
    try:
        prompt = f"""주제: {topic}
난이도: {difficulty}/5 (1=쉬움, 5=매우어려움)
개수: {count}개

{topic}에 대한 난이도 {difficulty} 수준의 객관식 퀴즈를 {count}개 생성해.

**중요:**
- 난이도 {difficulty}에 맞는 문제 출제
- 선택지는 A, B, C, D 네 개
- 정답은 반드시 하나만
- 해설은 구체적으로

JSON 배열만 출력:
[
  {{
    "question": "문제",
    "options": ["선택지A", "선택지B", "선택지C", "선택지D"],
    "correctAnswer": "선택지A",
    "explanation": "해설"
  }}
]

JSON만 출력, 마크다운 없이:"""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=4000,
            temperature=0.7
        )
        
        import json
        import re
        content = response.choices[0].message.content.strip()
        content = re.sub(r'^```json\s*', '', content)
        content = re.sub(r'\s*```$', '', content)
        content = content.strip()
        
        quizzes = json.loads(content)
        
        return jsonify({
            "success": True,
            "quizzes": quizzes,
            "count": len(quizzes)
        })
        
    except Exception as e:
        print(f"Quiz generation error: {e}")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
