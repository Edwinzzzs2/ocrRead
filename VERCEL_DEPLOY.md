# Vercel 部署指南

本文档介绍如何将 DDDDOCR API 服务部署到 Vercel 平台。

## 部署准备

### 1. 文件结构
确保项目包含以下文件：
```
├── api/
│   └── index.py          # Vercel 入口文件
├── ddddocr/              # 主要代码目录
├── vercel.json           # Vercel 配置文件
├── requirements.txt      # Python 依赖
└── README.md
```

### 2. 关键配置文件

#### vercel.json
- 定义 Python 运行时
- 配置路由规则
- 设置环境变量和函数超时

#### api/index.py
- Vercel Serverless 函数入口
- 适配 FastAPI 应用
- 处理导入错误

#### requirements.txt
- 使用 `opencv-python-headless` 而非 `opencv-python`（Vercel 兼容性更好）
- 包含所有必要的 API 依赖

## 部署步骤

### 方法一：通过 Vercel CLI

1. **安装 Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **登录 Vercel**
   ```bash
   vercel login
   ```

3. **部署项目**
   ```bash
   vercel
   ```

### 方法二：通过 GitHub 集成

1. **推送代码到 GitHub**
   ```bash
   git add .
   git commit -m "Add Vercel deployment configuration"
   git push origin main
   ```

2. **在 Vercel 控制台导入项目**
   - 访问 [vercel.com](https://vercel.com)
   - 点击 "New Project"
   - 选择 GitHub 仓库
   - 点击 "Deploy"

## 环境变量配置

在 Vercel 控制台的项目设置中，可以添加以下环境变量：

- `PYTHONPATH`: `.` (已在 vercel.json 中配置)
- 其他自定义环境变量（如需要）

## API 使用

部署成功后，可以通过以下方式使用 API：

### 1. 初始化服务
```bash
curl -X POST https://your-app.vercel.app/initialize \
  -H "Content-Type: application/json" \
  -d '{"ocr": true, "det": false}'
```

### 2. OCR 识别
```bash
curl -X POST https://your-app.vercel.app/ocr \
  -H "Content-Type: application/json" \
  -d '{"image": "base64_encoded_image_data"}'
```

### 3. 查看 API 文档
访问：`https://your-app.vercel.app/docs`

## 注意事项

### 1. 冷启动
- Vercel Serverless 函数存在冷启动时间
- 首次请求可能需要较长时间（10-30秒）
- 建议实现预热机制

### 2. 函数限制
- 最大执行时间：30秒（在 vercel.json 中配置）
- 内存限制：1024MB（免费版）
- 文件大小限制：50MB

### 3. 模型文件
- ONNX 模型文件会增加部署包大小
- 确保模型文件在 50MB 限制内
- 考虑使用外部存储（如 CDN）托管大型模型

### 4. 依赖优化
- 使用 `opencv-python-headless` 减少包大小
- 避免不必要的依赖
- 考虑使用 Docker 部署大型应用

## 故障排除

### 1. 导入错误
- 检查 `api/index.py` 中的错误处理
- 确保所有依赖都在 `requirements.txt` 中

### 2. 超时错误
- 增加 `vercel.json` 中的 `maxDuration`
- 优化代码性能
- 考虑异步处理

### 3. 内存不足
- 升级 Vercel 计划
- 优化模型加载
- 使用模型缓存

## 监控和日志

- 在 Vercel 控制台查看函数日志
- 使用 Vercel Analytics 监控性能
- 设置错误告警

## 成本考虑

- 免费版：每月 100GB-hours 执行时间
- Pro 版：$20/月，更多执行时间和功能
- 根据使用量选择合适的计划