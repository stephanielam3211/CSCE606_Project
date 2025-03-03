from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

OUTPUT_DIR = BASE_DIR / 'public' / 'output'
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

print(OUTPUT_DIR)