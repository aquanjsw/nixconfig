import json

from django.http import HttpRequest, JsonResponse
from django.conf import settings

SUBSCRIPTION_PATH = settings.SUBSCRIPTION_PATH

def config(request: HttpRequest):

    strict_route = request.GET.get('strict-route', '1') == '1'

    data = json.load(open(SUBSCRIPTION_PATH))

    data['tun']['strict-route'] = strict_route

    return JsonResponse(data)
