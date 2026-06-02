import json

from django.http import HttpRequest, HttpResponse
from django.conf import settings

def sing_box(request: HttpRequest):
    mtu_str = request.GET.get('mtu', '0')
    try:
        mtu = int(mtu_str)
    except ValueError:
        mtu = 0

    auto_redirect = request.GET.get('auto-redirect', '1') == '1'
    strict_route = request.GET.get('strict-route', '1') == '1'
    stack = request.GET.get('stack', '')
    log_level = request.GET.get('log-level', '')
    fakeip = request.GET.get('fakeip', '1') == '1'

    config = json.load(open(settings.SINGBOX_CONFIG_PATH))

    for inbound in config['inbounds']:
        if inbound['type'] == 'tun':
            if mtu > 0:
                inbound['mtu'] = mtu
            inbound['auto_redirect'] = auto_redirect
            inbound['strict_route'] = strict_route
            if stack:
                inbound['stack'] = stack

    if not fakeip:
        for rule in config['dns']['rules']:
            if rule['server'] == 'fakeip':
                config['dns']['rules'].remove(rule)

    if log_level:
        config['log']['level'] = log_level

    content = json.dumps(config, indent=2)
    return HttpResponse(content, content_type='application/json')
