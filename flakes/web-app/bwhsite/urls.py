import os
import subalter.views

from django.urls import path

urlpatterns = [
    path(os.environ["MIHOMO_URL_PATH"], subalter.views.mihomo),
    path(os.environ["SINGBOX_URL_PATH"], subalter.views.sing_box),
]
