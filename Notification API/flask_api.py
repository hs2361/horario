from flask import Flask, redirect, url_for, request
from firebase_admin import messaging, credentials, storage
import firebase_admin

# IMPORTANT: Change this to the path in which the .json file is stored in your system
cred = credentials.Certificate("/home/kaustubh/Desktop/Github/horario/Notification API/horario-b3703-firebase-adminsdk-v5o4t-a6b6d16f73.json")
firebase_admin.initialize_app(cred)
app = Flask(__name__)

@app.route('/send_notification/<topic>/<title>/<body>',methods = ['PUT'])
def success(topic,title,body):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        topic=topic,
    )
    response = messaging.send(message)
    return f"Successfully sent message:{response}"

if __name__ == '__main__':
   app.run(debug = True)