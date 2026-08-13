import json

from django.conf import settings
from django.http import HttpRequest, HttpResponse


def sing_box(request: HttpRequest):
    os = request.GET.get("os", "")
    if not os or os not in ["linux", "windows", "android"]:
        return HttpResponse("Invalid OS", status=400)

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

    if os != "linux":
        for server in config["dns"]["servers"]:
            if server["type"] == "dhcp":
                server["type"] = "local"
                break

    if os == "android":
        config["endpoints"] = [
            {
                "type": "tailscale",
                "tag": "tailscale-ep",
                "auth_key": extra["tailscale-auth-key"],
                "ephemeral": True,
            }
        ]
        for server in config["dns"]["servers"]:
            if server["type"] == "tailscale-dns":
                config["dns"]["servers"].remove(server)
        config["dns"]["servers"].append(
            {
                "tag": "tailscale-dns",
                "type": "tailscale",
                "endpoint": "tailscale-ep",
            }
        )
        for rule in config["dns"]["rules"]:
            if rule.get("server", None) == "tailscale-dns":
                config["dns"]["rules"].remove(rule)
        config["dns"]["rules"].append(
            {"server": "tailscale-dns", "ip_accept_any": True}
        )
        config["route"]["rules"].insert(
            0,
            {
                "preferred_by": ["tailscale-ep"],
                "outbound": "tailscale-ep",
            },
        )
        for inbound in config["inbounds"]:
            if inbound["type"] == "tun":
                inbound["route_exclude_address"].remove("100.64.0.0/10")
                inbound["route_exclude_address"].remove("fd7a:115c:a1e0::/48")
                break

    content = json.dumps(config, indent=2)
    return HttpResponse(
        content,
        content_type="application/json",
        headers={"Content-Disposition": "attachment; filename=config.json"},
    )
