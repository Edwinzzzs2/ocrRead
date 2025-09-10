# coding=utf-8
"""
Vercel部署入口文件
适配Vercel的Serverless函数
"""

import os
import sys
from pathlib import Path

# 添加项目根目录到Python路径
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

try:
    from ddddocr.api.server import create_app
    from ddddocr.api.server import service
except ImportError as e:
    print(f"Import error: {e}")
    # 创建一个简单的错误响应应用
    from fastapi import FastAPI
    from fastapi.responses import JSONResponse
    
    def create_app():
        app = FastAPI(title="DDDDOCR API - Import Error")
        
        @app.get("/")
        async def root():
            return JSONResponse({
                "error": "Failed to import ddddocr modules",
                "message": "Please ensure all dependencies are installed",
                "detail": str(e)
            }, status_code=500)
        
        return app

# 创建FastAPI应用实例
app = create_app()

# Vercel需要的handler函数
def handler(request, response):
    """Vercel serverless function handler"""
    return app(request, response)

# 如果直接运行此文件，启动开发服务器
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)