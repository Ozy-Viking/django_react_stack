from django.urls import path, re_path
from .views import index, static_files
from django.conf import settings
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.conf.urls.static import static

urlpatterns: list = [
    path("", index, name="home"),
]

if settings.DEBUG:
    urlpatterns += [re_path(r"^(?P<path>.*)$", static_files)]  # type: ignore
