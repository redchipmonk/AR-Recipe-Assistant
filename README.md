# AR-Recipe-Assistant

An augmented reality (AR) application that leverages computer vision and SLAM to detect and localize food items, then uses a GPT-base API to generate recipes. The system integrates YOLO for object detection, ORB-SLAM for tracking, and ARCore for the interface.

## Overview

The AR Recipe Assistant project aims to create an AR experience with a head-mounted display where users can:
- **Detect food items** in the real world using YOLO object detection.
- **Localize objects** in 3D space using ORB-SLAM.
- **Generate recipes** by filtering detected ingredients and querying a GPT-based API.
- (Stretch Goal) Access guided AR cooking instructions through an intuitive interface.

## Features

- **Real-Time Object Detection:** Identify food items in video streams.
- **3D World Mapping:** Persistently maps the environment.
- **GPT-Based Recipe Generation:** Filters detected ingredients and generates recipes.
- **AR Interface:** Displays detected food items and recipes on an AR overlay using an HMD.

## Hardware & Software Requirements

### Hardware
- **Mobile Phone with RGB Camera:** For capturing video.
- **AR Headset:** For enhanced AR immersion.

### Software
- **ORB-SLAM:** [GitHub Link](https://github.com/raulmur/ORB_SLAM)
- **YOLO:** [GitHub Link](https://github.com/THU-MIG/yolov10)
- **OpenAI GPT API:** [Documentation](https://platform.openai.com/docs/overview)
- **ARCore:** [Documentation](https://developers.google.com/ar)

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/AR-Recipe-Assistant.git
cd AR-Recipe-Assistant
```

## License
This project is licensed under the MIT License.
