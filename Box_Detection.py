import cv2
from ultralytics import YOLO
from collections import Counter
import firebase_admin
from firebase_admin import credentials, db
import sys
import numpy as np

FIREBASE_KEY_PATH = 'serviceAccountKey.json'
FIREBASE_DB_URL = 'https://new-project-30a62-default-rtdb.firebaseio.com'
MODEL_PATH = 'yolov10s.pt'
IMAGE_PATH = 'output_image.jpg'
DB_PATH = 'image_detection_counts'
OUTPUT_IMAGE_PATH = 'output_image1.jpg'


def initialize_firebase():
    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(FIREBASE_KEY_PATH)
            firebase_admin.initialize_app(cred, {
                'databaseURL': FIREBASE_DB_URL
            })
        print("Firebase initialized successfully.")
        return True
    except FileNotFoundError:
        print(f"ERROR: Firebase key file not found at '{FIREBASE_KEY_PATH}'")
    except ValueError:
        print(f"ERROR: Invalid Firebase Database URL: '{FIREBASE_DB_URL}'")
    except Exception as e:
        print(f"Unexpected error during Firebase init: {e}")
    return False


def load_model(model_path):
    try:
        model = YOLO(model_path)
        print(f"YOLO model loaded from '{model_path}'.")
        dummy_img = np.zeros((640, 480, 3), dtype=np.uint8)
        model(dummy_img, verbose=False)
        return model
    except FileNotFoundError:
        print(f"ERROR: Model file not found at '{MODEL_PATH}'")
    except Exception as e:
        print(f"Error loading model: {e}")
    return None


def store_in_firebase(data, path):
    if data is None:
        return
    try:
        ref = db.reference(path)
        ref.set(data)
        print(f"Firebase updated at '{path}'")
    except Exception as e:
        print(f"Error storing data in Firebase: {e}")


def process_image_file(model, image_path):
    frame = cv2.imread(image_path)
    if frame is None:
        print(f"ERROR: Could not open image file at '{image_path}'.")
        return None

    class_names_map = model.names
    results = model(frame, verbose=False)
    detection_counts = {}

    if results:
        r = results[0]
        annotated_frame = r.plot()

        try:
            cv2.imwrite(OUTPUT_IMAGE_PATH, annotated_frame)
        except Exception as e:
            print(f"Error saving output image: {e}")

        class_ids = r.boxes.cls.cpu().numpy().astype(int)
        if len(class_ids) > 0:
            id_counts = Counter(class_ids)
            detection_counts = {
                class_names_map[id]: count for id, count in id_counts.items()
            }
        else:
            detection_counts = {}

    return detection_counts


def main():
    if not initialize_firebase():
        sys.exit(1)

    model = load_model(MODEL_PATH)
    if not model:
        sys.exit(1)

    counts = process_image_file(model, IMAGE_PATH)

    if counts is not None:
        store_in_firebase(counts, DB_PATH)


if __name__ == "__main__":
    main()
