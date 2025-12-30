from PIL import Image
import sys

path = r"C:/Users/alext/.gemini/antigravity/brain/d1157a5c-d576-4965-94ae-c7c7f0d9160f/uploaded_image_1766840160517.jpg"
try:
    with Image.open(path) as img:
        print(f"Dimensions: {img.size}")
except Exception as e:
    print(f"Error: {e}")
