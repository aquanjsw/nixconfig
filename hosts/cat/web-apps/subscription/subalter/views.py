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
    os = request.GET.get("os", "")
    if os not in ["linux", "windows", "android"]:
        return HttpResponse(f"Invalid OS: '{os}'", status=400)

    config = json.load(open(settings.SETTINGS_FILE))
    extra = json.load(open(settings.EXTRA_SETTINGS_FILE))

    VLESS_UUID_MAP = extra["vless-uuids"]

    auto_redirect = request.GET.get("auto-redirect", "1") == "1"
    user = request.GET.get("user", "default")

    for outbound in config["outbounds"]:
        if outbound["type"] == "vless":
            outbound["uuid"] = VLESS_UUID_MAP[user]
            break

    for inbound in config["inbounds"]:
        if inbound["type"] == "tun":
            inbound["auto_redirect"] = os != "windows" and auto_redirect
            break

    return response(config)
