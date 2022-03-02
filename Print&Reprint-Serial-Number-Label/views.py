from django.shortcuts import render
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import generic
from lrm.print.print_all_labels import print_all_labels
from lrm.print.print_label import print_label

#=== LOCAL IMPORTS
from srv.database.db_actions import *
from srv.print.label.print_label import *

class PrintSerialNumber(LoginRequiredMixin, generic.ListView):
    template_name = 'print_sn/print_sn_list.html'
    def get(self, *args, **kwargs):
        context = {}
        viewTitle = 'Print Serial Number'
        context.update({'viewTitle': viewTitle})
        db_obj = DataLayer()
        db_conn = db_obj.connect()
        if db_conn is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            )
            return render(self.request, self.template_name, context)

        if 'errorMsg' in self.request.GET:
            error = self.request.GET['errorMsg']
            if error:
                context.update({ 'errorMsg': error })
        
        return render(self.request, self.template_name, context)

    def post(self, *args, **kwargs):
        context = {}
        error = {}
        data = self.request.POST       
        viewTitle = 'Print SN Label'
        context.update({'viewTitle': viewTitle})
        
        db_obj = DataLayer()
        db_conn = db_obj.connect()

        id = data.get('workorder_id').strip().upper()
        sp_params = db_obj.createparams(f"PRINT-SN,{id}")
        sp_result = db_obj.runstoredprocedure(db_conn,'lrm_wo_status_validation_sp', sp_params)

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if not 'workorder_id' in data:
            context.update({'result': 'Missing Workorder ID Parameter'})
            return JsonResponse(context, safe=False, status=400)

        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)            
        
        sp_params = db_obj.createparams(f"{id}")
        wo_info = db_obj.runfunction(db_conn,'lrm_get_wo_info', sp_params)

        sp_params = db_obj.createparams(f"{id}")
        sn_list = db_obj.runfunction(db_conn,'lrm_get_sn_by_wo', sp_params)

        keys = ['workorder_id', 'status_id', 'target_qty', 'skuno', 'production_version', 'sn_from', 'sn_to']
        values = [wo_info[0][i].strip().upper() for i in range(len(wo_info[0]))]
        workorder_info = {key:value for key,value in zip(keys,values)}

        context.update ({
            'workorder_info'     : workorder_info,
            'wo_info'            : wo_info,
            'serial_number_list' : sn_list,
            'production_version' : workorder_info['production_version'],
            'skuno'              : workorder_info['skuno']
        })
        
        return JsonResponse(context, safe=False)

def lrm_print_sn(request):

    if request.method == 'POST':        
        error = {}
        context = {}
        data = request.POST  

        db_obj = DataLayer()
        db_conn = db_obj.connect()

        id = data.get('workorder_id').strip().upper()
        sp_params = db_obj.createparams(f"PRINT-SN,{id}")
        sp_result = db_obj.runstoredprocedure(db_conn,'lrm_wo_status_validation_sp', sp_params)

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)

        sn = data.get('serial_number').strip().upper()
        wt = data.get('workorder_type').strip().upper()
        pf = data.get('profile').strip().upper()

        response = print_label(sn, wt, pf)      

        context.update ({
            'serial_number' : sn,
            'print_response': response,
        })
        
        return JsonResponse(context, safe=False, status=200)

def lrm_print_all_sn(request):

    if request.method == 'POST':        
        error = {}
        context = {}
        data = request.POST  

        db_obj = DataLayer()
        db_conn = db_obj.connect()

        id = data.get('workorder_id').strip().upper()
        wt = data.get('workorder_type').strip().upper()
        sk = data.get('skuno').strip().upper()
        pf = data.get('profile').strip().upper()
        
        if sk == '' or sk == None:
            error.update({'result':'SKU Can\'t Not Be Empty'})
            return JsonResponse(error, safe=False, status=400)

        sp_params = db_obj.createparams(f"{id}")
        sn_list = db_obj.runfunction(db_conn,'lrm_get_sn_by_wo', sp_params)

        sp_params = db_obj.createparams(f"PRINT-SN,{id}")
        sp_result = db_obj.runstoredprocedure(db_conn,'lrm_wo_status_validation_sp', sp_params)

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)

        response = print_all_labels(id, sn_list, wt, pf)       

        context.update ({
            'serial_number_list' : sn_list,
            'print_response': response
        })

        return JsonResponse(context, safe=False, status=200)
