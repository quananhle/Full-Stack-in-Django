from django.urls import path
from . import views

app_name = 'lrm'


# =================== MFG URLS ============================
urlpatterns = [
    path('print-sn/', views.PrintSerialNumber.as_view(), name='lrm_print_sn'),
    path('print-sn/label', views.lrm_print_sn, name='lrm_print_sn_label'),
    path('print-sn/all-label', views.lrm_print_all_sn, name='lrm_print_all_sn_label'),
]
