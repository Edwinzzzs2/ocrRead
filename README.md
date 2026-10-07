# ocrRead

基于 [ddddocr](https://github.com/sml2h3/ddddocr) 的验证码识别 HTTP 服务，可用于 PT Manager 等客户端。模型在服务器本地运行，不需要 GPU。

GitHub Actions 自动构建镜像并发布到 `ghcr.io/edwinzzzs2/ocrread`，支持 Linux x86_64 和 ARM64。部署时只需一个 Compose 文件。

## Docker Compose 部署

先在服务器安装 Docker 和 Docker Compose，然后创建 `docker-compose.yml`：

```yaml
services:
  ocrread:
    image: ghcr.io/edwinzzzs2/ocrread:latest
    container_name: ocrread
    restart: unless-stopped
    ports:
      - "8000:8000"
    mem_limit: 640m
```

在文件所在目录启动：

```bash
docker compose up -d
```

首次启动会自动下载镜像，无需下载项目源码、安装 Python 或在服务器构建镜像。服务自带模型，基本使用无需挂载数据目录。

打开 `http://服务器IP:8000/docs` 查看接口文档。远程访问时需要放行服务器的 TCP 8000 端口；如果使用域名反向代理，后端地址填写 `http://127.0.0.1:8000`（反代服务与 OCR 在同一台主机且反代使用宿主机网络时）。

如果宿主机 8000 端口已被占用，将映射改为 `"18000:8000"`，访问端口相应改为 18000。

## 简单使用

### PT Manager

在 PT Manager 的 OCR 服务地址中填写：

```text
http://服务器IP:8000
```

填写服务根地址即可，不要附加 `/ocr` 或 `/docs`。PT Manager 会自动初始化模型并调用识别接口。

### HTTP 接口

| 接口 | 方法 | 用途 |
| --- | --- | --- |
| `/health` | GET | 检查 HTTP 服务是否正常 |
| `/status` | GET | 查看模型状态；首次调用会自动加载 OCR 模型 |
| `/initialize` | POST | 选择并初始化模型 |
| `/ocr` | POST | 识别 Base64 编码的图片 |
| `/docs` | GET | 查看和调试接口 |

识别请求示例，将 `图片的Base64内容` 替换为实际图片数据：

```bash
curl -X POST http://服务器IP:8000/ocr \
  -H 'Content-Type: application/json' \
  -d '{"image":"图片的Base64内容","charset_range":"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"}'
```

成功时响应中的 `success` 为 `true`，识别文字位于 `data.text`：

```json
{
  "success": true,
  "message": "OCR识别成功",
  "data": {"text": "abc123", "probability": null}
}
```

## 更新与管理

更新镜像并启动新版本：

```bash
docker compose pull
docker compose up -d
```

查看状态、查看日志、重启或停止：

```bash
docker compose ps
docker compose logs --tail 100
docker compose restart
docker compose down
```

## 镜像发布

推送 `master`、`main` 上与镜像有关的代码，或推送 `v*` 标签时，GitHub Actions 会自动构建并发布镜像，也可在 Actions 页面手动运行 **Publish Docker image**。

默认分支发布 `latest` 和 `sha-提交号` 标签；版本标签发布同名镜像标签，例如 `v1.0.0`。需要固定版本时，将 Compose 中的 `latest` 换成对应标签。

首次发布后，仓库管理员需要在 GitHub 的 `Packages → ocrread → Package settings` 中将镜像可见性设为 **Public**，其他服务器才能直接下载，无需登录 GHCR。

## 原版说明

Python SDK、滑块识别、自定义模型等详细说明请查看 [ddddocr 原版文档](https://github.com/sml2h3/ddddocr#readme)。本项目使用 [MIT License](LICENSE)。
