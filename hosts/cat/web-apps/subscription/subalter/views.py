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
    tailscale = request.GET.get("tailscale", "0") == "1"

    config = json.load(open(settings.SETTINGS_FILE))
    extra_settings = json.load(open(settings.EXTRA_SETTINGS_FILE))

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

    if tailscale:
        config["endpoints"] = [
            {
                "type": "tailscale",
                "tag": "tailscale-ep",
                "auth_key": extra_settings["tailscale-auth-key"],
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

    content = json.dumps(config, indent=2)
    return HttpResponse(
        content,
        content_type="application/json",
        headers={"Content-Disposition": "attachment; filename=config.json"},
    )
