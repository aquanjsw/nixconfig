import json

from django.http import HttpRequest, HttpResponse
from django.conf import settings

MIHOMO_CONFIG_PATH = settings.MIHOMO_CONFIG_PATH
SINGBOX_CONFIG_PATH = settings.SINGBOX_CONFIG_PATH
DEFAULT_MTU = 1400

def sing_box(request: HttpRequest):
    mtu_str = request.GET.get('mtu', str(DEFAULT_MTU))
    try:
        mtu = int(mtu_str)
    except ValueError:
        mtu = DEFAULT_MTU

    auto_redirect = request.GET.get('auto-redirect', '1') == '1'
    strict_route = request.GET.get('strict-route', '1') == '1'
    stack = request.GET.get('stack', 'mixed')
    log_level = request.GET.get('log-level', 'info')

    config = json.load(open(SINGBOX_CONFIG_PATH))

    for inbound in config['inbounds']:
        if inbound['type'] == 'tun':
            inbound['mtu'] = mtu
            inbound['auto_redirect'] = auto_redirect
            inbound['strict_route'] = strict_route
            inbound['stack'] = stack

    config['log']['level'] = log_level

    content = json.dumps(config, indent=2)
    return HttpResponse(content, content_type='application/json')

def mihomo(request: HttpRequest):

    strict_route = request.GET.get('strict-route', '1') == '1'

    config = json.load(open(MIHOMO_CONFIG_PATH))

    config['tun']['strict-route'] = strict_route

    content = json.dumps(config, indent=2)
    return HttpResponse(content, content_type='application/json')
