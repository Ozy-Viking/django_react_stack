from django.conf import settings
from django.shortcuts import render
from django.views.static import serve
from loguru import logger

# Create your views here.


def index(request, *args, **kwargs):
    return render(request, "index.html")


def static_files(request, *args, **kwargs):
    if not settings.DEBUG:
        # No-op if not in debug mode or a non-local prefix.
        return []
    kwargs |= {"document_root": "static"}
    return serve(request=request, **kwargs)
