from django.contrib import admin
from django.contrib.auth.decorators import login_required
from django.contrib.auth import views as auth_views

from django.urls import path, include
from django.conf import settings
from django.conf.urls import url
from django.conf.urls.static import static

from django.views.generic.base import TemplateView
from django.views.generic import RedirectView
# import debug_toolbar
admin.site.site_header = 'Admin'
admin.site.index_title = 'Admin'

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/login/', auth_views.LoginView.as_view(), name='login'),
    path('accounts/logout/', auth_views.LogoutView.as_view(), name='logout'),
    #path('', login_required(TemplateView.as_view(template_name='main/dashboard.html')), name='home')
    path('', RedirectView.as_view(url='dashboard/', permanent=True), name='home')       

]

urlpatterns += [
    path('dashboard/', include('sadmin.urls')),  # ===== DASHBOARD ===== #
]

urlpatterns += [
    path('mfg/', include('mfg.urls')),  # ===== MFG / MODULE ===== #
    path('shp/', include('shp.urls')),  # ===== SHP / MODULE ===== #
    path('srv/', include('srv.urls')),  # ===== SRV / MODULE ===== #
    path('tls/', include('tls.urls')),  # ===== TLS / MODULE ===== #
    path('lrm/', include('lrm.urls')),  # ===== LRM / MODULE ===== #
    path('tst/', include('tst.urls')),  # ===== TST / MODULE ===== #
]

urlpatterns += [
    url('monitoring/', include('django_prometheus.urls')),
]

urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
