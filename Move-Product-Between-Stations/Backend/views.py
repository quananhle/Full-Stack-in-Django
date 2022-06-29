class ChangeStationView(LoginRequiredMixin, View):
    template_name = 'change_sn_station/change_station.html'

    def dispatch(self, request) -> HttpResponse:
        if request.method == 'POST':
            post_data = request.POST
            if post_data.get('function'):
                if post_data.get('function') == 'confirm()':
                    return self.confirm()
                elif post_data.get('function') == 'approval()':
                    return self.approval()
                else:
                    return self.get()
            else:
                return self.get()
        elif request.method == 'GET':
            get_data = request.GET
            if get_data.get('function') == 'populate()':
                return self.populate()
            else:
                return self.get()

    def get(self, *args, **kwargs):
        context = {}   
        viewTitle = 'Change SN Station'
        context.update({'viewTitle': viewTitle})
        username = self.request.user.username
        db_obj = DataLayer()
        sn_object = SerialNumber()
        db_conn = db_obj.connect()

        if db_conn is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            )
            sn_object.sadmin_log('EXCEPTION', viewTitle, 'FAIL', 'GET', context, username)
            return render(self.request, self.template_name, context)

        if 'errorMsg' in self.request.GET:
            error = self.request.GET['errorMsg']
            if error:
                context.update({ 'errorMsg': error })
            sn_object.sadmin_log('EXCEPTION', viewTitle, 'FAIL', 'GET', error, username)
        return render(self.request, self.template_name, context)

    def populate(self):
        context = {}
        error = {}

        viewTitle = 'Change SN Station'
        context.update({'viewTitle': viewTitle})

        sn_object = SerialNumber()
        db_obj = DataLayer()
        db_conn = db_obj.connect()

        data = self.request.GET
        serial_number = data.get('serial_number').strip().upper()
        username = data.get('profile').strip()

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            sn_object.sadmin_log('EXCEPTION', viewTitle, 'FAIL', serial_number, error, username)
            return JsonResponse(error, safe=False, status=400)

        if not serial_number or len(serial_number) == 0:
            error.update({'result': 'Missing Serial Number'})
            sn_object.sadmin_log('EXCEPTION', viewTitle, 'FAIL', serial_number, error, username)
            return JsonResponse(error, safe=False, status=400)

        #validate the serial number
        sp_params = db_obj.createparams(f"SN-VALIDATION,{serial_number}")
        sp_result = db_obj.runstoredprocedure(db_conn,'mfg_change_sn_station_validation', sp_params)

        if sp_result:
            error.update({'result' : sp_result})
            sn_object.sadmin_log('EXCEPTION', viewTitle, 'mfg_change_sn_station_validation', serial_number, sp_result, username)
            return JsonResponse(error, safe=False, status=400)
        else:
            sn_object.sadmin_log('READ', viewTitle, 'mfg_change_sn_station_validation', serial_number, 'SN-VALIDATION', username)

        #retrieve serial number details from database
        sp_params = db_obj.createparams(f"{serial_number}")
        sn_info = db_obj.runfunction(db_conn,'tls_get_sn_info', sp_params)
        sn_object.sadmin_log('READ', viewTitle, 'tls_get_sn_info', serial_number, f"Backend: ChangeStationView", username)

        #serial number details for info cards
        keys = ['workorder_id', 'station', 'last_station', 'skuno', 'production_version', 'route_id', 'status', 'row_id', 'passed_station', 'action', 'scan_date', 'scan_by']
        vals = [sn_info[0][i].strip().upper() for i in range(len(sn_info[0]))]
        serial_number_info = {key:value for key,value in zip(keys,vals)}

        #serial number details for tracking table
        sn_tracking_info_list = list()
        for info in sn_info:
            values = [info[i].strip().upper() for i in range(len(info))]
            sn_tracking_info = {key:value for key,value in zip(keys,values)}
            sn_tracking_info_list.append(sn_tracking_info)

        #retrieve stations in route of serial number
        params = db_obj.createparams(f"{serial_number},{serial_number_info['route_id']}")
        station_list = db_obj.runfunction(db_conn,'mfg_prd_flow_get_station', params)
        sn_object.sadmin_log('READ', viewTitle, 'mfg_prd_flow_get_station', serial_number, f"Backend: ChangeStationView", username)

        #station list and station sequences for drop-down and confirm button function
        station_info_dict = {'station_id': [], 'sequence': []}
        for station_info in station_list:
            station_info_dict['station_id'].append(station_info[0].strip().upper())
            station_info_dict['sequence'].append(station_info[1])

        context.update ({
            'sn_info'           : serial_number_info,
            'tracking_stations' : sn_tracking_info_list,
            'station_info'      : station_info_dict
        })
        sn_object.sadmin_log('CREATE', viewTitle, 'PASSED', serial_number, f"Backend: ChangeStationView", username)
        return JsonResponse(context, safe=False, status=200)

    def confirm(self):
        error = {}
        context = {}
        viewTitle = 'Change SN Station'
        sn_object = SerialNumber()
        data = self.request.POST

        db_obj = DataLayer()
        db_conn = db_obj.connect()
        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        sn = data.get('serial_number').strip().upper()
        st = data.get('station').strip().upper()
        us = data.get('profile').strip()

        #validate serial number and update new station
        sp_params = db_obj.createparams(f"CHANGE-SN-STATUS,{sn},{st},{us}")
        sp_result = db_obj.runstoredprocedure(db_conn,'mfg_change_sn_station', sp_params)
        
        if sp_result:
            #if work order is confirmed with SAP
            if sp_result == 'SAP-CWO':
                sn_object.sadmin_log('READ', viewTitle, 'mfg_change_sn_station', sn, 'SAP-CWO', us)
                context.update ({
                    'SAP_Confirmed' : sp_result
                })
                return JsonResponse(context, safe=False, status=200)
            else:
                error.update({'result':sp_result})
                sn_object.sadmin_log('EXCEPTION', viewTitle, 'mfg_change_sn_station', sn, sp_result, us)
                return JsonResponse(error, safe=False, status=400)
        else:
            sn_object.sadmin_log('READ', viewTitle, 'mfg_change_sn_station', sn, 'CHANGE-SN-STATUS', us)

        #retrieve updated serial number details from database
        sp_params = db_obj.createparams(f"{sn}")
        sn_info = db_obj.runfunction(db_conn,'tls_get_sn_info', sp_params)
        sn_object.sadmin_log('READ', viewTitle, 'tls_get_sn_info', sn, f"Backend: Confirm Button", us)

        #updated serial number details for info cards
        keys = ['workorder_id', 'station', 'last_station', 'skuno', 'production_version', 'route_id', 'status', 'row_id', 'passed_station', 'action', 'scan_date', 'scan_by']
        vals = [sn_info[0][i].strip().upper() for i in range(len(sn_info[0]))]
        serial_number_info = {key:value for key,value in zip(keys,vals)}

        #retrieve stations in route of serial number
        params = db_obj.createparams(f"{sn},{serial_number_info['route_id']}")
        station_list = db_obj.runfunction(db_conn,'mfg_prd_flow_get_station', params)
        sn_object.sadmin_log('READ', viewTitle, 'mfg_prd_flow_get_station', sn, f"Backend: ChangeStationView", us)

        #station list and station sequences for drop-down and confirm button function
        station_info_dict = {'station_id': [], 'sequence': []}
        for station_info in station_list:
            station_info_dict['station_id'].append(station_info[0].strip().upper())
            station_info_dict['sequence'].append(station_info[1])

        context.update ({
            'sn_info'           : serial_number_info,
            'station_info'      : station_info_dict
        })

        sn_object.sadmin_log('CREATE', viewTitle, 'PASSED', sn, f"Backend: Confirm Button", us)

        return JsonResponse(context, safe=False, status=200)

    def approval(self):
            context = {}
            error = {}
            data = self.request.POST  
            viewTitle = 'Change SN Station'
            sn_object = SerialNumber()

            db_obj = DataLayer()
            db_conn = db_obj.connect()
            if db_conn is None:
                error.update({'result':'There is a problem with Database connection, Call IT'})
                return JsonResponse(error, safe=False, status=400)

            #validate the inputs
            bpl_username  = data.get('username').strip()
            bpl_password  = data.get('password')
            serial_number = data.get('serial_number').strip().upper()
            station       = data.get('station').strip().upper()
            user_profile  = data.get('profile').strip()

            user = authenticate(username=bpl_username, password=bpl_password)
            if user:
                fn_params = db_obj.createparams(f"{'BPL'},{bpl_username}")
                fn_result = db_obj.runfunction(db_conn, 'mfg_qa_approval_ath_fn', fn_params)

                if fn_result:
                    result = fn_result[0][0].split('|')
                    status = result[0]
                    message = result[1]
                    if status == 'TRUE':
                        context.update({
                            'message': message
                        })
                        sn_object.sadmin_log('READ', viewTitle, 'mfg_qa_approval_ath_fn', bpl_username, message, user_profile)
                    else:
                        error.update({
                            'result': message
                        })
                        sn_object.sadmin_log('EXCEPTION', viewTitle, 'mfg_qa_approval_ath_fn', bpl_username, message, user_profile)
                        return JsonResponse(error, safe=False, status=400)
                else:
                    error.update({'result' : fn_result})
                    sn_object.sadmin_log('EXCEPTION', viewTitle, 'mfg_qa_approval_ath_fn', bpl_username, 'BPL', user_profile)
                    return JsonResponse(error, safe=False, status=400)
            else:
                error.update({'result' : 'Wrong Username or Password'})
                sn_object.sadmin_log('EXCEPTION', viewTitle, 'User Authentication Failed', bpl_username, 'BPL', user_profile)
                return JsonResponse(error, safe=False, status=400)

            #validate serial number and update new station
            sp_params = db_obj.createparams(f"SAP-CONFIRMED-WO,{serial_number},{station},{user_profile}")
            sp_result = db_obj.runstoredprocedure(db_conn,'mfg_change_sn_station', sp_params)

            if sp_result:
                error.update({'result' : sp_result})
                sn_object.sadmin_log('EXCEPTION', viewTitle, 'mfg_change_sn_station', serial_number, sp_result, user_profile)
                return JsonResponse(error, safe=False, status=400)
            else:
                sn_object.sadmin_log('READ', viewTitle, 'mfg_change_sn_station', serial_number, 'CHANGE-SN-STATUS', user_profile)

            #retrieve updated serial number details from database
            sp_params = db_obj.createparams(f"{serial_number}")
            sn_info = db_obj.runfunction(db_conn,'tls_get_sn_info', sp_params)
            sn_object.sadmin_log('READ', viewTitle, 'tls_get_sn_info', serial_number, f"Backend: Confirm Button", serial_number)

            #updated serial number details for info cards
            keys = ['workorder_id', 'station', 'last_station', 'skuno', 'production_version', 'route_id', 'status', 'row_id', 'passed_station', 'action', 'scan_date', 'scan_by']
            vals = [sn_info[0][i].strip().upper() for i in range(len(sn_info[0]))]
            serial_number_info = {key:value for key,value in zip(keys,vals)}

            #retrieve stations in route of serial number
            params = db_obj.createparams(f"{serial_number},{serial_number_info['route_id']}")
            station_list = db_obj.runfunction(db_conn,'mfg_prd_flow_get_station', params)
            sn_object.sadmin_log('READ', viewTitle, 'mfg_prd_flow_get_station', serial_number, f"Backend: ChangeStationView", user_profile)

            #station list and station sequences for drop-down and confirm button function
            station_info_dict = {'station_id': [], 'sequence': []}
            for station_info in station_list:
                station_info_dict['station_id'].append(station_info[0].strip().upper())
                station_info_dict['sequence'].append(station_info[1])

            context.update ({
                'sn_info'           : serial_number_info,
                'station_info'      : station_info_dict
            })
            
            sn_object.sadmin_log('CREATE', viewTitle, 'PASSED', serial_number, f"Backend: Approve Button", user_profile)
            return JsonResponse(context, safe=False, status=200)
