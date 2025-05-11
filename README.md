# TASKORO - Task Management App

A beautiful and intuitive task management application built with Flutter and Firebase.

## Features

- **Authentication:** Email/Password, Google Sign-In, Facebook Sign-in, Twitter
- **Task Management:** Create, Read, Update, Delete tasks
- **Advanced Features:** Reminders, sorting tasks, filtering by date/priority, search functionality
- **Beautiful UI:** Clean and intuitive interface following modern design principles

## Technology Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Authentication, Firestore)
- **Design:** Based on Figma design

## Project Structure

```tree
lib/
  ├── screens/       # App screens and pages
  ├── widgets/       # Reusable UI components
  ├── models/        # Data models
  ├── services/      # Backend services
  ├── utils/         # Utility functions
  └── theme/         # App theming and styling
```

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to launch the app

## Firebase Setup

To connect the app with Firebase backend:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Flutter app to your Firebase project
3. Download and add the `google-services.json` file (Android) or `GoogleService-Info.plist` (iOS)
4. Enable Authentication and Firestore in Firebase console

## Design Reference

The app implements the design from [Figma](https://www.figma.com/design/m7pOBTA5YKlZBNpwCHkkvl/Task-Planner-App-1?node-id=512-4549&t=4MztXiqOg1i0RCV6-1)
