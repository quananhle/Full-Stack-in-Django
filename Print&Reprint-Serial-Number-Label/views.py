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

        keys = ['workorder_id', 'status_id', 'target_qty', 'skuno', 'production_version', 'sn_from', 'sn_to', 'order_type', 'object_type']
        values = [wo_info[0][i].strip().upper() for i in range(len(wo_info[0]))]
        workorder_info = {key:value for key,value in zip(keys,values)}

        context.update ({
            'workorder_info'     : workorder_info,
            'wo_info'            : wo_info,
            'serial_number_list' : sn_list,
            'production_version' : workorder_info['production_version'],
            'skuno'              : workorder_info['skuno'],
            'order_type'         : workorder_info['order_type'],
            'object_type'        : workorder_info['object_type'],
        })
        
        return JsonResponse(context, safe=False)

def lrm_print_sn(request):

    if request.method == 'POST':        
        error = {}
        context = {}
        data = request.POST  

        db_obj = DataLayer()
        printService = PrintLabel()
        sn_object = SerialNumber()
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

        sn = data.get('serial_number').strip()
        tp = data.get('order_type').strip()
        pf = data.get('profile').strip()
        ot = data.get('object_type').strip()        
        
        object_type = ot
        trans_type  = ot

        log = 'Print {} Serial Number Label: Failed to Set Up Printer'.format(tp)
        printService.get_bt_data(object_type)
        if printService.error:
            context.update ({
                'message' : printService.error, 
                'result' : 'FAIL', 
                'sn' : sn,
                'log_message' : log
            })
            sn_object.sadmin_log('EXCEPTION', 'Print {} Serial Number Label'.format(tp), 'FAIL', sn, log, pf)
            return context

        printService.get_data(sn, trans_type)
        if printService.error:
            context.update ({
                'message' : printService.error, 
                'result' : 'FAIL', 
                'sn' : sn,
                'log_message' : log
            })
            sn_object.sadmin_log('EXCEPTION', 'Print {} Serial Number Label'.format(tp), 'FAIL', sn, log, pf)
            return context

        log = 'Print {} Serial Number Label: Failed to Connect Printer'.format(tp)
        printService.set_print()
        if printService.error:
            context.update ({
                'message' : printService.error, 
                'result' : 'FAIL', 
                'sn' : sn,
                'log_message' : log
            })
            sn_object.sadmin_log('EXCEPTION', 'Print {} Serial Number Label'.format(tp), 'FAIL', sn, log, pf)
            return context

        context.update ({
            'message' : printService.printResult, 
            'result' : 'PASS', 
            'sn' : sn,
            'log_message' : log
        })

        message = 'Successfully Generated Label {} of Work Order {}'.format(sn, id)
        sn_object.sadmin_log('CREATE', 'Print {} Serial Number Label'.format(tp), 'PASS', sn, message, pf)

        context.update ({
            'serial_number' : sn,
            'print_response': message
        })
        
        return JsonResponse(context, safe=False, status=200)


def lrm_print_all_sn(request):

    if request.method == 'POST':        
        error = {}
        context = {}
        data = request.POST  

        db_obj = DataLayer()
        printService = PrintLabel()
        sn_object = SerialNumber()
        db_conn = db_obj.connect()

        id = data.get('workorder_id').strip()
        tp = data.get('order_type').strip()
        sk = data.get('skuno').strip()
        pf = data.get('profile').strip()
        ot = data.get('object_type').strip()
        
        if sk == '' or sk == None:
            error.update({'result':'SKU Can\'t Not Be Empty'})
            return JsonResponse(error, safe=False, status=400)

        sp_params = db_obj.createparams(f"{id}")
        serial_number_list = db_obj.runfunction(db_conn,'lrm_get_sn_by_wo', sp_params)

        sp_params = db_obj.createparams(f"PRINT-SN,{id}")
        sp_result = db_obj.runstoredprocedure(db_conn,'lrm_wo_status_validation_sp', sp_params)

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)

        for i in range (len(serial_number_list)):
            serial_number = serial_number_list[i]
            object_type = ot
            trans_type  = ot

            log = 'Print {} Serial Number Label: Failed to Set Up Printer'.format(tp)
            printService.get_bt_data(object_type)
            if printService.error:
                context.update ({
                    'message' : printService.error, 
                    'result' : 'FAIL', 
                    'sn' : serial_number,
                    'log_message' : log
                })
                sn_object.sadmin_log('EXCEPTION', 'Print {} Serial Number Label'.format(tp), 'FAIL', serial_number, log, pf)
                return context

            printService.get_data(serial_number, trans_type)
            if printService.error:
                context.update ({
                    'message' : printService.error, 
                    'result' : 'FAIL', 
                    'sn' : serial_number,
                    'log_message' : log
                })
                sn_object.sadmin_log('EXCEPTION', 'Print {} Serial Number Label'.format(tp), 'FAIL', serial_number, log, pf)
                return context

            log = 'Print {} Serial Number Label: Failed to Connect Printer'.format(tp)
            printService.set_print()
            if printService.error:
                context.update ({
                    'message' : printService.error, 
                    'result' : 'FAIL', 
                    'sn' : serial_number,
                    'log_message' : log
                })
                sn_object.sadmin_log('EXCEPTION', 'Print {} Serial Number Label'.format(tp), 'FAIL', serial_number, log, pf)
                return context
        context.update ({
            'message' : printService.printResult, 
            'result' : 'PASS', 
            'sn' : serial_number,
            'log_message' : log
        })

        message = 'Successfully Generated All Labels of Work Order {}'.format(id)
        sn_object.sadmin_log('CREATE', 'Print {} Serial Number Label'.format(tp), 'PASS', serial_number, message, pf)

        context.update ({
            'serial_number_list' : serial_number_list,
            'print_response': message
        })

        return JsonResponse(context, safe=False, status=200)
