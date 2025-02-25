from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
from ultralytics import YOLO
from fastapi.responses import JSONResponse

app = FastAPI()

model = YOLO("yolov8n.pt")

@app.post("/detect")
async def detect_objects(file: UploadFile = File(...)):
  image_bytes = await file.read()
  image = np.frombuffer(image_bytes, np.uint8)
  img = cv2.imdecode(image, cv2.IMREAD_COLOR)

  results = model(img)

  detections = []
  for result in results:
    for box in result.boxes.data:
      x1, y1,x2, y2, conf, cls = box.tolist()
      detections.append({
        "x1": x1, "y1": y1,
        "x2": x2, "y2": y2,
        "confidence": conf,
        "class": int(cls)
      })

  return JSONResponse(content={"detections": detections})