#!/bin/bash
set -euxo pipefail

WHEEL_PATH="${1:-}"
if [ -z "$WHEEL_PATH" ]; then
  echo "Usage: $0 /path/to/package.whl"
  exit 1
fi

APP_DIR="/opt/stock_dashboard"
VENV_DIR="$APP_DIR/.venv"

apt-get update
apt-get install -y python3 python3-pip python3-venv nginx curl

mkdir -p "$APP_DIR"
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip setuptools wheel
"$VENV_DIR/bin/pip" install "$WHEEL_PATH"

cat > /etc/systemd/system/stock-dashboard.service <<'EOF'
[Unit]
Description=Stock Dashboard Django app
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/opt/stock_dashboard
Environment=DJANGO_SETTINGS_MODULE=stock_project.settings
Environment=DJANGO_DEBUG=0
ExecStart=/opt/stock_dashboard/.venv/bin/gunicorn --workers 2 --bind 0.0.0.0:8000 stock_project.wsgi:application
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/nginx/sites-available/stock-dashboard <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/stock-dashboard /etc/nginx/sites-enabled/stock-dashboard
rm -f /etc/nginx/sites-enabled/default

systemctl daemon-reload
systemctl enable --now stock-dashboard
systemctl restart nginx

curl -fsS http://127.0.0.1/health/ || true
