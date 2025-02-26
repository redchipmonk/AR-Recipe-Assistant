from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
import cv2
import numpy as np
import base64
from ultralytics import YOLO

app = FastAPI()

# Load YOLO model
model = YOLO("yolov8n.pt")

def get_colors(cls_num):
  """Generate unique colors for each class index"""
  base_colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255)]
  color_index = cls_num % len(base_colors)
  increments = [(1, -2, 1), (-2, 1, -1), (1, -1, 2)]
  color = [base_colors[color_index][i] + increments[color_index][i] *
           (cls_num // len(base_colors)) % 256 for i in range(3)]
  return tuple(color)

@app.get("/")
async def home():
  """Main HTML Page"""
  try:
    with open("../client/index.html", "r") as f:
      return HTMLResponse(content=open("../client/index.html").read(), status_code=200)
  except FileNotFoundError:
    return HTMLResponse(content="<h1>File not found: index.html</h1>", status_code=404)

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
  """Real-time object detection"""
  await websocket.accept()
  try:
    while True:
      # Receive base64 image from client
      data = await websocket.receive_text()
      if not data:
        print("Received empty data from client")
        continue
      try:
        # Decode base64 image
        if "," in data:
          _, base64_data = data.split(",", 1)
        else:
          base64_data = data
        image_data = base64.b64decode(base64_data)
        np_arr = np.frombuffer(image_data, np.uint8)
        if np_arr.size == 0:
          print("Empty image buffer")
          continue
        frame = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        if frame is None:
          print("OpenCV failed to decode image")
          continue
      except Exception as e:
        print(f"Image decoding error: {e}")
        continue

      results = model.predict(frame, stream=True)
      for result in results:
        classes_names = result.names
        for box in result.boxes:
          if box.conf[0] > 0.4:
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            cls = int(box.cls[0])
            class_name = classes_names[cls]
            color = get_colors(cls)
            # Draw bounding box
            cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
            cv2.putText(frame, f"{class_name} {box.conf[0]:.2f}", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

      _, buffer = cv2.imencode('.jpg', frame)
      processed_base64 = base64.b64encode(buffer).decode('utf-8')
      await websocket.send_text(f"data:image/jpeg;base64,{processed_base64}")

  except Exception as e:
    print(f"WebSocket error: {e}")
  finally:
    await websocket.close()