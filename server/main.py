from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
from ultralytics import YOLO
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],
  allow_credentials=True,
  allow_methods=["*"],
  allow_headers=["*"],
)

model = YOLO("yolov8n.pt")

CLASS_LABELS = model.names

@app.post("/detect")
async def detect_objects(file: UploadFile = File(...)):
  image_bytes = await file.read()
  image = np.frombuffer(image_bytes, np.uint8)
  img = cv2.imdecode(image, cv2.IMREAD_COLOR)

  results = model.predict(img)

  detections = []
  for result in results:
    for box in result.boxes:
      x1, y1,x2, y2 = box.xyxy[0].tolist()
      conf = float(box.conf[0])
      class_id = int(box.cls[0])
      class_name = CLASS_LABELS.get(class_id, f"Class {class_id}")
      detections.append({
        "x1": x1, "y1": y1,
        "x2": x2, "y2": y2,
        "confidence": conf,
        "class_id": class_id,
        "class_name": class_name
      })

  return JSONResponse(content={"detections": detections})