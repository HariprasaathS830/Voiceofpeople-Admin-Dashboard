import os
# pyrefly: ignore [missing-import]
import uvicorn
# pyrefly: ignore [missing-import]
from fastapi import FastAPI
# pyrefly: ignore [missing-import]
from fastapi.responses import PlainTextResponse

# Import db and auth from the local firebase configuration module to match original behavior
from firebase import db, auth

app = FastAPI()

# Test route
@app.get("/", response_class=PlainTextResponse)
def home():
    return "Civil App Backend is running! 🚀"

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3000))
    print(f"Server running on port {port}")
    # Run the server on 0.0.0.0 to allow access from other devices if needed
    uvicorn.run(app, host="0.0.0.0", port=port)
