from django.urls import path
from subalter.views import sing_box

urlpatterns = [path("config.json", sing_box, name="sing_box")]
