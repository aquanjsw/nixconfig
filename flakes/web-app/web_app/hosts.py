from django.conf import settings
from django_hosts import patterns, host

host_patterns = patterns('',
    host(settings.SUBSCRIPTION_DOMAIN, settings.ROOT_URLCONF, name='subscription')
)
