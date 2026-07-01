import json

from django.conf import settings
from django.http import HttpRequest, HttpResponse


def sing_box(request: HttpRequest):
    mtu_str = request.GET.get("mtu", "0")
    try:
        mtu = int(mtu_str)
    except ValueError:
        mtu = 0

    strict_route = request.GET.get("strict-route", "1") == "1"
    stack = request.GET.get("stack", "")
    log_level = request.GET.get("log-level", "debug")
    ipv6 = request.GET.get("ipv6", "1") == "1"
    system = request.GET.get("system", "unknown")

    config = json.load(open(settings.SETTINGS_FILE))

    for inbound in config["inbounds"]:
        if inbound["type"] == "tun":
            if mtu > 0:
                inbound["mtu"] = mtu
            inbound["auto_redirect"] = system != "windows"
            inbound["strict_route"] = strict_route
            if stack:
                inbound["stack"] = stack

    config["log"]["level"] = log_level

    config["dns"]["strategy"] = "ipv4_only" if not ipv6 else "prefer_ipv4"

    if system != "linux":
        for server in config["dns"]["servers"]:
            if server["type"] == "dhcp":
                server["type"] = "local"
                break

    content = json.dumps(config, indent=2)
    return HttpResponse(
        content,
        content_type="application/json",
        headers={"Content-Disposition": "attachment; filename=config.json"},
    )
