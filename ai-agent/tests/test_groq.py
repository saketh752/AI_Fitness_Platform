from app.llm.groq_client import GroqClient
from app.llm.prompts import SYSTEM_PROMPT


def test_groq_fitness_response():
    client = GroqClient()

    response = client.chat(
        [
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            {
                "role": "user",
                "content": "What is progressive overload?",
            },
        ]
    )

    assert response
    assert response.choices
    assert response.choices[0].message.content