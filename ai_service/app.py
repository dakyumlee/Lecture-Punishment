from flask import Flask, request, jsonify
from openai import OpenAI
import os
import json
import re
import random

app = Flask(__name__)
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY', 'dummy-key'))

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy"})

@app.route('/generate-rage', methods=['POST'])
def generate_rage():
    data = request.json
    student_name = data.get('studentName', '학생')
    wrong_answer = data.get('wrongAnswer', '')
    correct_answer = data.get('correctAnswer', '')
    question = data.get('question', '')
    combo_broken = data.get('comboBroken', False)
    
    intensity = "extreme" if combo_broken else "normal"
    
    fallback_messages = [
        "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ",
        "목졸라뿐다",
        "니대가리로 이해가 가긴 하겠니",
        "야 그건 기본이잖아!",
        "이게 안 되면 앞으로 어쩌려고?",
        "복습 좀 해라, 제발",
        "이 정도도 못 풀면 뭐하러 왔어?",
        "아니 그걸 틀려? 진짜?",
        "다시 한 번 생각해봐... 아니다, 생각 자체를 안 하는구나"
    ]
    
    try:
        prompt = f"""당신은 전설적인 강사 "허태훈"입니다. 학생이 문제를 틀렸을 때 특유의 독설로 멘탈을 흔듭니다.

학생: {student_name}
문제: {question}
정답: {correct_answer}
학생 답: {wrong_answer}
상황: {"콤보가 끊겼습니다!" if combo_broken else "틀렸습니다"}

허태훈 스타일로 {"매우 격렬하게" if intensity == "extreme" else "날카롭게"} 한 문장으로 꾸짖으세요.

참고 스타일:
- "너는 복습을 했니? 했으면 이럴 리가 없지 ㅋㅋ"
- "목졸라뿐다"
- "야 그건 기본이잖아!"

한 문장만:"""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.9
        )
        
        rage_message = response.choices[0].message.content.strip()
        
        return jsonify({
            "success": True,
            "message": rage_message,
            "intensity": intensity
        })
        
    except Exception as e:
        return jsonify({
            "success": True,
            "message": random.choice(fallback_messages),
            "intensity": intensity
        })

@app.route('/generate-praise', methods=['POST'])
def generate_praise():
    data = request.json
    combo = data.get('combo', 3)
    
    fallback = ["오, 이건 좀 하는데?", "드디어 제대로 하네", "이 정도면 복습 좀 했구나"]
    
    try:
        prompt = f"""허태훈 강사가 학생의 {combo}연속 정답에 감탄합니다.

허태훈 스타일로 짧게 칭찬하세요:
- "오, 이건 좀 하는데?"
- "드디어 제대로 하네"

한 문장만:"""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=50,
            temperature=0.8
        )
        
        return jsonify({
            "success": True,
            "message": response.choices[0].message.content.strip()
        })
        
    except:
        return jsonify({
            "success": True,
            "message": random.choice(fallback)
        })

@app.route('/generate-quizzes', methods=['POST'])
def generate_quizzes():
    data = request.json
    topic = data.get('topic')
    difficulty = data.get('difficulty', 3)
    
    quiz_counts = {1: 10, 2: 15, 3: 20, 4: 25, 5: 30}
    actual_count = quiz_counts.get(difficulty, 20)
    
    try:
        prompt = f"""주제 '{topic}'에 대한 난이도 {difficulty}/5 퀴즈를 {actual_count}개 생성하세요.

JSON 배열 형식으로만 출력:
[
  {{
    "question": "문제",
    "options": ["A", "B", "C", "D"],
    "correctAnswer": "A",
    "explanation": "해설"
  }}
]

반드시 {actual_count}개를 생성하고, JSON만 출력하세요."""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=3000,
            temperature=0.7
        )
        
        content = response.choices[0].message.content.strip()
        content = re.sub(r'^```json\s*', '', content)
        content = re.sub(r'\s*```$', '', content)
        
        quizzes = json.loads(content)
        
        return jsonify({
            "success": True,
            "quizzes": quizzes,
            "count": len(quizzes)
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
