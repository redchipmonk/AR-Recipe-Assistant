const video = document.getElementById("video");
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");
const output = document.getElementById("output")

let ws;
const WS_URL = "ws://localhost:8000/ws";

function connectWebSocket() {
  ws = new WebSocket(WS_URL);
  ws.onopen = () => console.log("WebSocket connected");
  ws.onmessage = (event) => {
    console.log("Received frame");
    output.src = event.data;
  };
  ws.onerror = (error) => console.error("WebSocket error:", error);
  ws.onclose = () => {
    console.warn("WebSocket connection lost.");
  }
}

async function startCamera() {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({video: true});
    video.srcObject = stream;
    video.onloadeddata = () => {
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      startStreaming();
    };
  } catch (error) {
    console.error("Error accessing camera:", error);
  }
}

function startStreaming() {
  setInterval(() => {
    if (ws.readyState === WebSocket.OPEN) {
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      const frameData = canvas.toDataURL("image/jpeg");
      ws.send(frameData);
    }
  }, 400);
}

connectWebSocket();
startCamera();