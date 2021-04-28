from flask import Flask, request
from flask_firebase_admin import FirebaseAdmin
from firebase_admin import credentials, messaging

app = Flask(__name__)
app.config["FIREBASE_ADMIN_CREDENTIAL"] = credentials.Certificate(
    "./horario-b3703-firebase-adminsdk-v5o4t-a6b6d16f73.json")
firebase = FirebaseAdmin(app)


@app.route('/send_notification/', methods=['POST'])
@firebase.jwt_required
def success() -> str:
    print(request.json)
    message = messaging.Message(
        notification=messaging.Notification(
            title=request.json['title'],
            body=request.json['body']
        ),
        topic=request.json['topic'],
    )
    response = messaging.send(message)
    return f"Successfully sent message:{response}"


app.run(debug=True)
