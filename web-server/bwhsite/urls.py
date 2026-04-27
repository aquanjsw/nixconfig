import subalter.views
from django.urls import path

urlpatterns = [
    path('config.json', subalter.views.config),
]
