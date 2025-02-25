const video = document.getElementById("video");
const captureBtn = document.getElementById("capture");
const canvas = document.getElementById("canvas");
const detectionsDiv = document.getElementById("detections");

const ctx = canvas.getContext("2d");

async function startCamera() {
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
    console.error("getUserMedia is not supported in this browser");
  }
  try {
    const stream = await navigator.mediaDevices.getUserMedia({video: {facingMode: "environment"}});
    video.srcObject = stream;
  } catch (error) {
    console.error("Error accessing camera:", error);
  }
}

captureBtn.addEventListener("click", async () => {
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

  canvas.toBlob(async (blob) => {
    if (!blob) {
      console.error("Failed to capture image from canvas");
      return;
    }
    let formData = new FormData();
    formData.append("file", blob, "frame.jpg");

    try {
      const response = await fetch("http://localhost:8000/detect/", {
        method: "POST",
        body: formData
      });
      if (!response.ok) {
        console.error("Backend error:", await response.text());
      }
      const result = await response.json();
      detectionsDiv.innerHTML = JSON.stringify(result.detections, null, 2);
      drawDetections(result.detections);
    } catch (error) {
      console.error("Error sending frame:", error);
    }
  }, "image/jpeg");
});

function drawDetections(detections) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
  detections.forEach(detection => {
    const {x1, y1, x2, y2, confidence, class_name } = detection;
    ctx.strokeStyle = "red";
    ctx.lineWidth = 2;
    ctx.strokeRect(x1, y1, x2 - x1, y2 - y1);
    ctx.fillStyle = "red";
    ctx.font = "16px Arial";
    ctx.fillText(`${class_name} (${(confidence * 100).toFixed(1)}%)`, x1, y1 - 5);
  });
}

(async () => {
  await startCamera();
})();