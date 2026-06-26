# Voice of People - Backend API

This is the backend API for the Voice of People Admin Dashboard project, built with **FastAPI** (Python).

## Prerequisites

- Python 3.8 or higher
- Firebase Service Account Key (`serviceAccountKey.json`)

## Setup Instructions

1. **Navigate to the Backend Directory:**
   ```bash
   cd backend
   ```

2. **Create a Virtual Environment:**
   ```bash
   python -m venv .venv
   ```

3. **Activate the Virtual Environment:**
   - **macOS/Linux:**
     ```bash
     source .venv/bin/activate
     ```
   - **Windows:**
     ```cmd
     .venv\Scripts\activate
     ```

4. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Add Firebase Service Account Key:**
   Get your Firebase admin SDK service account credentials file from Firebase Console, rename it to `serviceAccountKey.json`, and place it in the `src/` directory:
   `backend/src/serviceAccountKey.json`

## Running the Server

Start the development server with:
```bash
python src/index.py
```

The API will be available at:
- **Base URL:** http://localhost:3000
- **Interactive Documentation (Swagger UI):** http://localhost:3000/docs
