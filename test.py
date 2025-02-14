from pathlib import Path

# Define the output directory
output_dir = Path("app/output")

# Ensure the directory exists before writing
output_dir.mkdir(parents=True, exist_ok=True)

# Test writing a file
try:
    test_file = output_dir / "test_write.txt"
    with open(test_file, "w") as f:
        f.write("Test file write successful!")
    print(f"✅ Successfully wrote to {test_file}")
except Exception as e:
    print(f"❌ Error writing to {test_file}: {e}")

# Clean up the test file

