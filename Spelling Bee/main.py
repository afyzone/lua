import random
import uvicorn
import ngrok
import keyboard
import subprocess
import time
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()
subprocess.Popen('start cmd /k ngrok http 5000', shell=True)

max_wpm = 180
min_wpm = 120

def get_typing_delay():
    min_delay = 60 / (max_wpm * 5)
    max_delay = 60 / (min_wpm * 5)
    
    return random.uniform(min_delay, max_delay)


class Message(BaseModel):
    message: str


@app.post("/")
async def receive_data(data: Message):
    word = data.message
    print(f'Received {word}')
    if word:
        for letter in word:
            keyboard.write(letter)
            time.sleep(get_typing_delay())

        keyboard.press_and_release("enter")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
