import requests

url = "http://localhost:8000/detect/"
files = {"file": open("./dog_bike_car.jpg", "rb")}
response = requests.post(url, files=files)

print(response.json())