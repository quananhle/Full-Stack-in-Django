from django.shortcuts import render
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import generic
from lrm.print.print_all_labels import print_all_labels
from lrm.print.print_label import print_label

#=== LOCAL IMPORTS
from srv.database.db_actions import *
from srv.print.label.print_label import *
from mfg.wip_flow.sn_object import SerialNumber

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

        # Input to be validated by a stored procedure on database
        id = data.get('workorder_id').strip().upper()
        sp_params = db_obj.createparams(f"PRINT-SN,{id}")
        sp_result = db_obj.runstoredprocedure(db_conn,'lrm_wo_status_validation_sp', sp_params)

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if not 'workorder_id' in data:
            context.update({'result': 'Missing Workorder ID Parameter'})
            return JsonResponse(context, safe=False, status=400)
        
        # If not passed validation, stored procedure in database to return the exception notice to backend and send to frontend to display
        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)            
        
        # If passed validation, get related data of input using a function in database
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

def print_all_labels(workorder, serial_number_list, workorder_type, profile):
    print (serial_number_list)
    context = {}
    log = ''

    if workorder_type == 'PMWO':
        transType = 'PRD-SN-LABEL'
        objectType = 'PRD-SN-LABEL'
    if workorder_type == 'PMCK':
        transType = 'CK-SN-LABEL'
        objectType = 'CK-SN-LABEL'        
    if workorder_type == '1GWO':
        transType = '1G-PRD-SN-LABEL'
        objectType = '1G-PRD-SN-LABEL'

    for i in range(len(serial_number_list)):
        object_value = serial_number_list[i]
        print (object_value)

        '''
        // Hashtable for serial_number and skuno

        keys = ['serial_number', 'skuno']
        values = [object_value[j] for j in range(len(object_value))]
        sn_info = {key:value for key,value in zip(keys,values)}
        '''
        printService = PrintLabel()
        sn_object = SerialNumber()
        serial_number = object_value[0]

        log = 'Print Batch Labels: Failed to Set Up Printer'
        printService.get_bt_data(objectType)
        if printService.error:
            context.update ({
                'message' : printService.error, 
                'result' : 'FAIL', 
                'sn' : serial_number,
                'log_message' : log
            })
            sn_object.sadmin_log('EXCEPTION', 'Print SN Label', 'FAIL', serial_number, log, profile)
            return context

        printService.get_data(serial_number, transType)
        if printService.error:
            context.update ({
                'message' : printService.error, 
                'result' : 'FAIL', 
                'sn' : serial_number,
                'log_message' : log
            })
            sn_object.sadmin_log('EXCEPTION', 'Print SN Label', 'FAIL', serial_number, log, profile)
            return context

        log = 'Print Batch Labels: Failed to Connect Printer'
        printService.set_print()
        if printService.error:
            context.update ({
                'message' : printService.error, 
                'result' : 'FAIL', 
                'sn' : serial_number,
                'log_message' : log
            })
            sn_object.sadmin_log('EXCEPTION', 'Print SN Label', 'FAIL', serial_number, log, profile)
            return context

    context.update ({
        'message' : printService.printResult, 
        'result' : 'PASS', 
        'sn' : serial_number,
        'log_message' : log
    })

    message = 'Successfully Generated All Labels of Work Order: {}'.format(workorder)
    sn_object.sadmin_log('CREATE', 'Print SN Label', 'PASS', serial_number, message, profile)

    return context

def print_label(serial_number, workorder_type, profile):
    log = ''
    if workorder_type == 'PMWO':
        transType = 'PRD-SN-LABEL'
        objectType = 'PRD-SN-LABEL'
    if workorder_type == 'PMCK':
        transType = 'CK-SN-LABEL'
        objectType = 'CK-SN-LABEL'    
    if workorder_type == '1GWO':
        transType = '1G-PRD-SN-LABEL'
        objectType = '1G-PRD-SN-LABEL'            

    printService = PrintLabel()
    object_value = serial_number

    context = {}

    printService = PrintLabel()
    sn_object = SerialNumber()

    log = 'Reprint Single Label: Failed to Set Up Printer'
    printService.get_bt_data(objectType)
    if printService.error:
        context.update ({
            'message' : printService.error, 
            'result' : 'FAIL', 
            'sn' : object_value,
            'log_message' : log
        })
        sn_object.sadmin_log('EXCEPTION', 'Print SN Label', 'FAIL', object_value, log, profile)
        return context

    printService.get_data(object_value, transType)
    if printService.error:
        context.update ({
            'message' : printService.error, 
            'result' : 'FAIL', 
            'sn' : object_value,
            'log_message' : log
        })
        sn_object.sadmin_log('EXCEPTION', 'Print SN Label', 'FAIL', object_value, log, profile)
        return context

    log = 'Reprint Single Label: Failed to Connect Printer'
    printService.set_print()
    if printService.error:
        context.update ({
            'message' : printService.error, 
            'result' : 'FAIL', 
            'sn' : object_value,
            'log_message' : log
        })
        sn_object.sadmin_log('EXCEPTION', 'Print SN Label', 'FAIL', object_value, log, profile)

        return context

    context.update ({
        'message' : printService.printResult, 
        'result' : 'PASS', 
        'sn' : object_value,
        'log_message' : log
    })
    message = 'Successfully Generated Label: {}'.format(object_value)
    sn_object.sadmin_log('CREATE', 'Print SN Label', 'PASS', object_value, message, profile)
    return context
