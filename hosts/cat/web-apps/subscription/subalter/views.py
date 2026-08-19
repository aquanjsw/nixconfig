import json

from django.conf import settings
from django.http import HttpRequest, HttpResponse


def response(config):
    content = json.dumps(config, indent=2)
    return HttpResponse(
        content,
        content_type="application/json",
        headers={"Content-Disposition": "attachment; filename=config.json"},
    )


def sing_box(request: HttpRequest):
    role = request.GET.get("role", "client")
    if role not in ["client", "server"]:
        return HttpResponse(f"Invalid role: '{role}'", status=400)

    if role == "server":
        server = json.load(open(settings.SERVER_SETTINGS_FILE))
        return response(server)

    os = request.GET.get("os", "")
    if os not in ["linux", "windows", "android"]:
        return HttpResponse(f"Invalid OS: '{os}'", status=400)

    server = request.GET.get("server", "")

    config = json.load(open(settings.SETTINGS_FILE))
    extra = json.load(open(settings.EXTRA_SETTINGS_FILE))

    VLESS_UUID_MAP = extra["vless-uuids"]

    auto_redirect = request.GET.get("auto-redirect", "1") == "1"
    user = request.GET.get("user", "default")

    for outbound in config["outbounds"]:
        if outbound["type"] == "vless":
            outbound["uuid"] = VLESS_UUID_MAP[user]
            if server:
                outbound["server"] = server
                outbound["tls"]["server_name"] = settings.STOLEN_SERVER
            break

    for inbound in config["inbounds"]:
        if inbound["type"] == "tun":
            inbound["auto_redirect"] = os != "windows" and auto_redirect
            break

    return response(config)
