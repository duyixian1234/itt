from flask import Flask, request
from PIL import Image
from transformers import BlipForConditionalGeneration, BlipProcessor

processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-base")
model = BlipForConditionalGeneration.from_pretrained(
    "Salesforce/blip-image-captioning-base"
)
print("Model loaded")

app = Flask(__name__)


@app.post("/recognize")
def recognize():
    file = request.files["file"]
    raw_image = Image.open(file.stream).convert("RGB")
    inputs = processor(raw_image, return_tensors="pt")
    out = model.generate(**inputs, max_new_tokens=256)
    return processor.decode(out[0], skip_special_tokens=True)
