from django.urls import path
from . import views

app_name = 'tls'

urlpatterns = [
    # Added by Quan GDLAWSBS - Upload AFBS WH Tool, 01/26/2024, BEGIN
    path('tls_upload_afbs/', views.UploadAFBSToolView.as_view(), name = 'tls_upload_afbs')
    # Added by Quan GDLAWSBS - Upload AFBS WH Tool, 01/26/2024, BEGIN
]
