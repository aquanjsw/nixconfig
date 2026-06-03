import subalter.views

from django.conf import settings
from django.urls import path

urlpatterns = [
    path(settings.SINGBOX_URL_PATH, subalter.views.sing_box),
]
