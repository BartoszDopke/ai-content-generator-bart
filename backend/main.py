import json
from google import genai


def lambda_handler(event, context):
    try:
        # Read plain text body from event
        user_input = event.get("body", "").strip()

        if not user_input:
            return {"statusCode": 400, "body": "Missing input"}

        # Call Gemini API
        client = genai.Client()
        response = client.models.generate_content(
            model="gemini-2.5-flash", contents=user_input
        )

        return {"statusCode": 200, "body": json.dumps({"response": response.text})}

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
