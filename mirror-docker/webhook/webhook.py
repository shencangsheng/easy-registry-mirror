from flask import Flask, request, jsonify # type: ignore
import subprocess

app = Flask(__name__)

@app.route('/pull-event', methods=['POST'])
def handle_pull_event():
    event_data = request.json
    image_name = extract_image_name(event_data)
    if image_name:
        sync_image(image_name)
    return jsonify({"status": "received"}), 200

def extract_image_name(event_data):
    try:
        # 提取事件中镜像的名称
        image_name = event_data['events'][0]['target']['repository']
        return image_name
    except (KeyError, IndexError):
        return None

def sync_image(image_name):
    # 从中央仓库拉取镜像
    subprocess.run(["unix://docker.sock"])
    subprocess.run(["docker", "pull", f"docker.io/{image_name}"])
    # 标记镜像为本地注册表
    subprocess.run(["docker", "tag", f"docker.io/{image_name}", f"mirror-docker:5000/{image_name}"])
    # 推送镜像到本地注册表
    subprocess.run(["docker", "push", f"your-registry-host:5000/{image_name}"])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)