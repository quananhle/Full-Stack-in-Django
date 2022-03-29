from django.urls import path
from . import views

app_name = 'mfg'

# =================== WIP URLS ============================
urlpatterns = [
    path('wip/mo_manager/detail/<pk>', views.WipModelManagerDetailView.as_view(), name='wip_mo_manager_detail'),
    path('wip/mo_manager/update', views.mfg_material_master_update_serialization, name='mfg_serialization_update'),
    path('wip/mo_manager/update/serialization', views.mfg_material_update_serialization, name='mfg_material_update_serialization'),
]
