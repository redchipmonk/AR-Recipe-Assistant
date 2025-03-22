# AR-Recipe-Assistant

A real-time augmented reality (AR) application that automatically detects the current step in a recipe using only visual input. Built for iOS with Apple ARKit, this assistant leverages the GPT-4o-mini vision model to guide users through recipes with minimal interaction.

## Overview

This project introduces two generalizable methods for automatic recipe step detection in augmented reality:
### Method 1: YOLO + LLM
- Detects objects in the camera feed
- Keeps track of object history and state
- Uses an LLM to infer the current recipe step
### Method 2: Vision-Language Model
- Uses a VLM (GPT-4o) to infer the current step directly from the camera image

## Features

- **Recipe Step Detection** via visual input
- **Recipe Generation** from ingredients in the scene
- **On-device AR Interface** using Apple ARKit
- **GPT-4o Integration** for LLM & VLM reasoning
- **Object Detection** powered by YOLOv8 on-device

## Usage

### Requirements
- iOS device
- Xcode with ARKit support
- OpenAI API key for GPT-4o

### Install & Run
```bash
git clone https://github.com/redchipmonk/AR-Recipe-Assistant.git
cd AR-Recipe-Assistant/AR-Recipe-Assistant
open AR-Recipe-Assistant.xcodeproj
```
1. Configure the OpenAI API key
2. Choose YOLO or VLM from settings
3. Press "Generate Recipe" while pointing the camera at the ingredients

## License
This project is licensed under the MIT License.
