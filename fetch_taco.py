import urllib.request
import json
import re

URLS = [
    "https://raw.githubusercontent.com/giuzus/taco-api/main/db/taco.json",
    "https://raw.githubusercontent.com/isaacbatst/taco/master/taco.json",
    "https://raw.githubusercontent.com/raulfdm/taco-api/master/db/data.json",
    "https://raw.githubusercontent.com/raulfdm/taco-api/master/db/taco.json",
    "https://raw.githubusercontent.com/taco-api/taco-api/master/taco.json",
    "https://raw.githubusercontent.com/machine-learning-mocha/taco/master/data/taco.json",
    "https://raw.githubusercontent.com/Unicamp-Taco/taco-api/main/data/taco.json"
]

data = None
for url in URLS:
    try:
        print(f"Trying {url}...")
        req = urllib.request.urlopen(url)
        data = json.loads(req.read())
        print(f"SUCCESS at {url} with {len(data)} items")
        break
    except Exception as e:
        print(f"Failed: {e}")

if data:
    with open('taco_downloaded.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
else:
    print("Could not download TACO json")
