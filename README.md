Box Detection & Size Analysis System
This project uses YOLOv10 to detect boxes and K-Means Clustering to automatically group them into similar size categories. The detection counts are synced in real-time to Firebase, allowing a Flutter application to monitor the inventory live.

🚀 Features
Size Grouping: Automatically categorizes boxes into "Size 1," "Size 2," and "Size 3" based on their pixel area.
Real-time Sync: Uses Firebase Realtime Database to update the Flutter app instantly after detection.
Sorted Ranking: Ensures "Size 1" always represents the smallest group detected.
Cross-Platform: Monitor your box inventory from any Android or iOS device.

🛠️ Tech Stack
Object Detection: Ultralytics YOLOv10
Machine Learning: Scikit-Learn (K-Means Clustering)
Backend: Firebase Realtime Database
Mobile App: Flutter
Image Processing: OpenCV

📋 Prerequisites
Before running the project, ensure you have:
Python 3.8+ installed.
Firebase Project: A project set up at Firebase Console.
Service Account Key: Download your serviceAccountKey.json from Firebase Settings and place it in the root folder.

💻 Installation & Setup
1. Python Environment
Install the required libraries:
pip install ultralytics scikit-learn firebase-admin opencv-python

2. Running Detection
Update the FIREBASE_DB_URL in p_pro.py and run:
python 
Box_Detection.py
3. Flutter App
Navigate to your flutter project folder.
Run flutter pub get to install dependencies.
Run flutter run on your device.

📂 Project Structure
Box_Detection.py: Main Python script for detection and Firebase sync.
lib/: Flutter source code for the real-time dashboard.
requirements.txt: Python library dependencies.
.gitignore: Prevents large model files and private keys from being uploaded.
