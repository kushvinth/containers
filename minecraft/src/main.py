from flask import Flask, jsonify
import subprocess
import os
from dotenv import load_dotenv


app = Flask(__name__)

# Local Env
load_dotenv()

## Hotspot configuration
HOTSPOT_IFNAME = os.getenv("HOTSPOT_IFNAME")
HOTSPOT_NAME = os.getenv("HOTSPOT_NAME")
HOTSPOT_SSID = os.getenv("HOTSPOT_SSID")
HOTSPOT_PASSWORD = os.getenv("HOTSPOT_PASSWORD")

## Localtion Env
MINECRAFT_DIR = os.getenv("MINECRAFT_DIR")
PAPERMC_DIR = MINECRAFT_DIR + "/paperMC" ## Perfect with my LTS

# TMUX session names
MINECRAFT_SESSION = "minecraft"

##TODO: Add API Auth
@app.route("/server/<action>", methods=["GET"]) #Better With Nginx
def control_server(action):
    try:
        if action == "start_minecraft":
            # Enable hotspot (runs once, not inside tmux)
            subprocess.Popen([
                "nmcli", "device", "wifi", "hotspot",
                "ifname", HOTSPOT_IFNAME,
                "con-name", HOTSPOT_NAME,
                "ssid", HOTSPOT_SSID,
                "password", f"{HOTSPOT_PASSWORD}"
            ])
            
            # Start Minecraft server inside tmux
            subprocess.Popen([
                "tmux", "new-session", "-d",
                "-s", MINECRAFT_SESSION,
                f"bash -c 'cd {PAPERMC_DIR} && java -Xms6G -Xmx8G -jar paper.jar nogui'" #TODO: Make this oneline
            ])
            
        if action == "just_start_minecraft":
            # Start Minecraft server inside tmux
            subprocess.Popen([
                "tmux", "new-session", "-d",
                "-s", MINECRAFT_SESSION,
                f"bash -c 'cd {PAPERMC_DIR} && java -Xms6G -Xmx8G -jar paper.jar nogui'" #TODO: Make this oneline
            ])

            return jsonify({"status": "Minecraft server starting..."}), 200
        
        elif action == "stop_minecraft":
            # Stop Minecraft gracefully
            subprocess.Popen([
                "tmux", "send-keys", "-t", MINECRAFT_SESSION, "stop", "ENTER"
            ])
            
            subprocess.Popen([
		  "nmcli", "device", "disconnect", HOTSPOT_IFNAME
	    ])
            return jsonify({"status": "Minecraft server stopping and hotspot disabled..."}), 200

        elif action == "reboot":
            subprocess.Popen(["sudo", "reboot"])
            return jsonify({"status": "Server rebooting..."}), 200

        else:
            return jsonify({"error": "Unknown command"}), 400

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
