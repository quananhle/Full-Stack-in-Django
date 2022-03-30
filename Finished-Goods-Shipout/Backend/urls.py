from django.urls import path
from . import views

app_name = 'shp'

urlpatterns = [
    path('wh/shipout/', views.WarehouseShipoutView.as_view(), name='shp_wh_shipout'),
    path('wh/shipout/load_md/', views.WarehouseShipoutView.as_view(), name='sh_wh_ship_out_load_md'),
    path('wh/shipout/shipload/', views.wh_shipout_finish, name='sh_wh_ship_out_shipload'),
]

