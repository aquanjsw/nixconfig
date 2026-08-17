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

    # legacy standalone tailscale
    if os == "windows":
        for server in config["dns"]["servers"]:
            if server.get("type", "") == "tailscale":
                config["dns"]["servers"].remove(server)
                break
        config["dns"]["servers"].append(
            {
                "type": "udp",
                "tag": "tailscale-dns",
                "bind_interface": "tailscale0",
                "server": "100.100.100.100",
            }
        )

        for rule in config["dns"]["rules"]:
            if rule.get("server", "") == "tailscale-dns":
                rule["domain_suffix"] = [".ts.net"]
                break

        for rule in config["route"]["rules"]:
            if rule.get("outbound", "") == "ts-ep":
                config["route"]["rules"].remove(rule)
                break

        for inbound in config["inbounds"]:
            if inbound.get("type", "") == "tun":
                inbound["route_exclude_address"] = [
                    "192.168.0.0/16",
                    "10.0.0.0/8",
                    "224.0.0.0/4",
                    "100.64.0.0/10",
                    "fd7a:115c:a1e0::/48",
                ]
                break

        config.pop("endpoints")

    return response(config)
