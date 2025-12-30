from PIL import Image, ImageFilter

input_path = r"C:/Users/alext/.gemini/antigravity/brain/d1157a5c-d576-4965-94ae-c7c7f0d9160f/uploaded_image_1766840160517.jpg"
output_path = r"C:/Users/alext/.gemini/antigravity/brain/d1157a5c-d576-4965-94ae-c7c7f0d9160f/nutriz_feature_graphic_fixed.png"

def create_landscape_from_portrait(img_path, target_size=(1024, 500)):
    with Image.open(img_path) as img:
        # Create base canvas
        canvas = Image.new('RGB', target_size)
        
        # 1. Create blurred background
        # Resize to cover the width (1024)
        bg_scale = target_size[0] / img.width
        bg_new_height = int(img.height * bg_scale)
        bg = img.resize((target_size[0], bg_new_height), Image.Resampling.LANCZOS)
        # Crop the center vertical part (500px high)
        top = (bg_new_height - target_size[1]) // 2
        bg_cropped = bg.crop((0, top, target_size[0], top + target_size[1]))
        # Blur it
        bg_blurred = bg_cropped.filter(ImageFilter.GaussianBlur(radius=30))
        canvas.paste(bg_blurred, (0, 0))
        
        # 2. Place original in center
        # Resize to fit height (500)
        fg_scale = target_size[1] / img.height
        fg_new_width = int(img.width * fg_scale)
        fg = img.resize((fg_new_width, target_size[1]), Image.Resampling.LANCZOS)
        
        # Center position
        left = (target_size[0] - fg_new_width) // 2
        canvas.paste(fg, (left, 0))
        
        canvas.save(output_path)
        print(f"Saved to {output_path}")

create_landscape_from_portrait(input_path)
