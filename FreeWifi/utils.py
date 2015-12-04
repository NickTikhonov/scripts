import subprocess

def random_mac():
    subprocess.call("sudo spoof-mac randomize wi-fi".split())

def connect_hotspot(ssid):
    subprocess.call("networksetup -setairportnetwork en0 {}".format(ssid).split())

