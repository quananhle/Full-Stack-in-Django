from django.shortcuts import render
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import View
from django.http import JsonResponse
from django.shortcuts import render
from django.http import JsonResponse

#=== LOCAL IMPORTS
from srv.database.db_actions import *

class WipModelManagerDetailView(LoginRequiredMixin, View):
    template_name = 'mo_manager/model_detail.html'

    def get(self, *args, **kwargs):
        context = {}
        model_id = self.kwargs.get('pk')

        db_obj = DataLayer()
        db_conn = db_obj.connect()    
        viewTitle = 'Model Manager Detail'

        if db_conn is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            ) 
            return render(self.request, self.template_name, context)

        if 'errorMsg' in self.request.GET:
            error = self.request.GET['errorMsg']
            if error:
                context.update(
                    { 'errorMsg': error }
                )
        
        sp_params = DataLayer().createparams(f"{model_id}")
        model_manager_info = DataLayer().runfunction(db_conn,'mfg_model_manager_update_fn', sp_params)
        model_information = model_manager_info[0]

        context.update (
            {
                'viewTitle'   : viewTitle,
                'model_info'  : model_manager_info,
                'model_id'    : model_information[0],
                'keypart'     : model_information[1],
                'mask_rule'   : model_information[2],
                'category_id' : model_information[3],
                'plant'       : model_information[4],
                'sap_changed' : model_information[5],
                'esp_desc'    : model_information[6],
                'fracc_nico'  : model_information[7],
                'uom'         : model_information[8],
                'hst'         : model_information[9],
                'fracc_digits': model_information[10],
                'tech_desc'   : model_information[11]
            }
        )

        return render(self.request, self.template_name,context)

    def post(self, *args, **kwargs):
        context = {}
        error = {}
        data = self.request.POST
        viewTitle = 'Model Manager Detail'
        context.update({'viewTitle': viewTitle})

        db_obj = DataLayer()
        db_conn = db_obj.connect()

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if 'errorMsg' in self.request.GET:
            error = self.request.GET['errorMsg']
            if error:
                context.update(
                    { 'errorMsg': error }
                )                   
        
        model_id = data.get('model_id').strip().upper()
        username = data.get('profile').strip().upper()  
        trans_type = data.get('trans_type').strip().upper()

        if trans_type == 'UPDATE-MAIN':

            keypart = data.get('keypart').strip().upper()
            mask = data.get('mask_rule').strip().upper()
            mat_type = data.get('material_type').strip().upper()

            if keypart == '' and mask == '' and mat_type == '':
                sp_params = db_obj.createparams(f"{'UPDATE-MAIN'},{model_id},{keypart},{mask},{mat_type},{username},{''},{''}")
                sp_result = db_obj.runstoredprocedure(db_conn,'mfg_material_details_update_sp', sp_params)        
                if sp_result:
                    error.update({'result' : sp_result})
                    return JsonResponse(error, safe=False, status=400)    

            if model_id and (keypart or mask or mat_type):
                print(model_id, [keypart, mask, mat_type], username)
                params = db_obj.createparams(f"{'UPDATE-MAIN'},{model_id},{keypart},{mask},{mat_type},{username},{''},{''}")
                sp_result = db_obj.runstoredprocedure(db_conn, 'mfg_material_details_update_sp', params)
                if sp_result:
                    error.update({'result' : sp_result})
                    return JsonResponse(error, safe=False, status=400)   

        if trans_type == 'UPDATE-DATA-RELATED':

            hst = data.get('hst').strip().upper()
            fracc_digits = data.get('fracc_digits').strip().upper()

            if hst == '' and fracc_digits == '':
                sp_params = db_obj.createparams(f"{'UPDATE-MAIN'},{model_id},{''},{''},{''},{username},{hst},{fracc_digits}")
                sp_result = db_obj.runstoredprocedure(db_conn,'mfg_material_details_update_sp', sp_params)        
                if sp_result:
                    error.update({'result' : sp_result})
                    return JsonResponse(error, safe=False, status=400)   

            if model_id and (hst or fracc_digits):
                print(model_id, [hst, fracc_digits], username)
                params = db_obj.createparams(f"{'UPDATE-DATA-RELATED'},{model_id},{''},{''},{''},{username},{hst},{fracc_digits}")
                sp_result = db_obj.runstoredprocedure(db_conn, 'mfg_material_details_update_sp', params)
                if sp_result:
                    error.update({'result' : sp_result})
                    return JsonResponse(error, safe=False, status=400)  

        sp_params = DataLayer().createparams(f"{model_id}")
        model_manager_info = DataLayer().runfunction(db_conn,'mfg_model_manager_update_fn', sp_params)

        context.update ({
                'viewTitle': viewTitle,
                'mm_info' : model_manager_info
            })

        return JsonResponse(context, safe=False, status=200)


def mfg_material_update_serialization(request):
    if request.method == 'POST':
        context = {}
        error = {}
        data = request.POST
        viewTitle = 'Model Manager Detail'
        context.update({'viewTitle': viewTitle})

        db_obj = DataLayer()
        db_conn = db_obj.connect()

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if 'errorMsg' in request.GET:
            error = request.GET['errorMsg']
            if error:
                context.update(
                    { 'errorMsg': error }
                )                   
        
        model_id          = data.get('model_id').strip().upper()
        username          = data.get('profile').strip().upper()  
        keypart           = data.get('keypart').strip().upper()  
        mask              = data.get('mask_rule').strip().upper()
        cat_id            = data.get('category_id').strip().upper()
        esp_desc          = data.get('spanish_description').strip().upper().replace(",",";")
        fracc_nico        = data.get('fracc_nico').strip().upper()  
        uom_value         = data.get('uom_value').strip().upper()  
        hst_usa           = data.get('hst').strip().upper()
        fracc_digits      = data.get('fracc_digits').strip().upper()
        tech_desc         = data.get('technical_desc').strip().upper().replace(",",";")
        trans_type_master = data.get('trans_type_master').strip().upper()
        trans_type_detail = data.get('trans_type_detail').strip().upper()   

        if keypart == '' and mask == '' and cat_id == '' and esp_desc == '' and fracc_nico == '' and uom_value == '' and hst_usa == '' and fracc_digits == '' and tech_desc == '':
            params = db_obj.createparams(f"{'CHECK'},{model_id},{''},{''},{''},{username},{''},{''},{''},{''},{''},{''}")
            sp_result = db_obj.runstoredprocedure(db_conn, 'mfg_material_details_update_sp', params)    
            if sp_result:
                error.update({'result' : sp_result})
                return JsonResponse(error, safe=False, status=400)

        if model_id and (keypart or mask or cat_id):
            params = db_obj.createparams(f"{trans_type_master},{model_id},{keypart},{mask},{cat_id},{username},{''},{''},{''},{''},{''},{''}")
            sp_result = db_obj.runstoredprocedure(db_conn, 'mfg_material_details_update_sp', params)
            if sp_result:
                error.update({'result' : sp_result})
                return JsonResponse(error, safe=False, status=400)   

        if model_id and (esp_desc or fracc_nico or uom_value or hst_usa or fracc_digits or tech_desc):
            params = db_obj.createparams(f"{trans_type_detail},{model_id},{''},{''},{''},{username},{esp_desc},{fracc_nico},{uom_value},{hst_usa},{fracc_digits},{tech_desc}")
            sp_result = db_obj.runstoredprocedure(db_conn, 'mfg_material_details_update_sp', params)
            if sp_result:
                error.update({'result' : sp_result})
                return JsonResponse(error, safe=False, status=400)        

        sp_params = DataLayer().createparams(f"{model_id}")
        model_manager_info = DataLayer().runfunction(db_conn,'mfg_model_manager_update_fn', sp_params)

        context.update (
            {
                'successMsg' : 'Success',
                'viewTitle': viewTitle,
                'mm_info' : model_manager_info
            })

        return JsonResponse(context, safe=False, status=200)



def mfg_material_master_update_serialization(request):

    def post(request):
        print(request)
    
        data = request.POST
        
        model_id = data.get('model_id')
        serialization_type = data.get('serialization_type')
        manufacturer_pn = data.get('manufacturer_pn')
        aws_pn = data.get('aws_manufacturer')
        spanish_desc = data.get('spanish_desc')
        tech_desc = data.get('tech_description')
        fracc_nico = data.get('fracc_nico')
        uom_value = data.get('uom_value')
        uom = data.get('uom')
        hst_usa =  data.get('hst_usa') 
        username = data.get('profile') 

        print(model_id, serialization_type,manufacturer_pn,aws_pn,spanish_desc,fracc_nico,uom_value,uom,hst_usa, username)

        try:
            db = DataLayer()
            db_conn = db.connect()
            params = db.createparams(f"{model_id},{manufacturer_pn},{aws_pn},{spanish_desc},{tech_desc},{fracc_nico},{uom_value},{uom},{hst_usa},{serialization_type},{username}")
            print (params)
            sp_result = db.runstoredprocedure(db_conn, 'mfg_update_serializationtype', params)
            print ('sp_result: ', sp_result)
        except Exception as e:
            print(e)

    if request.method == 'POST':
        return post(request)
