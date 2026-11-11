# 1. Use a modern, active Debian version (Bookworm)
FROM python:3.11-slim

# 2. Install system tools
RUN apt-get update && apt-get install -y git ffmpeg mediainfo

# 3. Clone the bot repo
RUN git clone https://github.com/1Danish-00/CompressorBot.git /app
WORKDIR /app

# 4. Patch requirements and install
RUN sed -i '/pyaesni/d' requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir --upgrade telethon lxml_html_clean fastapi uvicorn

# 5. Patch the old Telegram API attribute
RUN find . -type f -name "*.py" -exec sed -i 's/\.user\./\.users\[0\]\./g' {} +

# 6. Create a lightweight dummy web server for Render's port binding
RUN printf 'from fastapi import FastAPI\napp = FastAPI()\n@app.get("/")\ndef read_root():\n    return {"status": "CompressorBot is Alive"}\n' > dummy_server.py

# 7. Start both the web server and the bot
CMD uvicorn dummy_server:app --host 0.0.0.0 --port ${PORT:-10000} & python start.py
