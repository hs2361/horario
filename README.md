# Horario
A Class Scheduling and Notes Sharing app for students.

## Features
* Users can add classes to their weekly schedule, along with their timings and the link to join the class.
* Users can also add assignments to their schedule along with the deadline.
* Horario will remind the user of their class or assignment using a push notification.
* Users can click on the notification to join the class directly.
* Users can upload notes with their group of fellow students.
* Users can also send requests for notes from their group.
* Horario organizes notes in a systematic manner, arranged by subject.
* Users can also search for notes by subject, notes name or file name.
* Users can change their display name and their password using the profile menu.

## Installation
If you're an end user, simply install the APK file provided [here](https://github.com/hs2361/horario/raw/master/app-release.apk)

### Local setup
If you wish to set-up the project locally, follow these instructions:
* Clone this repository to your computer
* Create a new [Firebase project](https://console.firebase.google.com)
* Add an Android app to the project, with the package name "com.horario.horario"
* Download the google-services.json file and add it to horario/android/app/
* Then install the app's dependencies as follows:
```sh
cd horario/
flutter pub get
```
* Finally, start the app on a connected device using:
```sh
flutter run
```
