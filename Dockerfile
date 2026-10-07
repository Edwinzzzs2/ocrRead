FROM python:3.11-slim-bookworm

WORKDIR /app
LABEL org.opencontainers.image.source="https://github.com/Edwinzzzs2/ocrRead" \
      org.opencontainers.image.licenses="MIT"

# Linux 使用无界面的 OpenCV，只安装 OCR 运行所需的系统库。
RUN apt-get update && \
    apt-get install -y --no-install-recommends libglib2.0-0 libgomp1 && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 只复制 OCR 包及内置模型，本地配置和部署文件不会进入镜像。
COPY ddddocr ./ddddocr
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    OMP_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=5)"

# 与 Vercel 使用相同入口，提供 PT Manager 所需的 /status、/initialize、/ocr。
# 固定一个进程，避免重复加载模型及初始化请求落到不同进程。
CMD ["python", "-m", "uvicorn", "ddddocr.api.server:create_app", "--factory", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
