class MCCodeToolNewView(LoginRequiredMixin, View):
    template_name = 'mc_code/mc_code_new.html'

    def __init__(self):
        self.context = {}
        self.fn_error = None   

    def dispatch(self, request) -> HttpResponse:
        if request.method == 'POST':
            post_data = request.POST
            return self.get()
        elif request.method == 'GET':
            get_data = request.GET
            return self.get()

    def get(self, *args, **kwargs):
        viewTitle = 'MC Code - New'

        context = {}

        username = self.request.user.username

        db = None
        db_obj = DataLayer()
        db_conn = db_obj.connect()    

        if db_conn is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            ) 
            return render(self.request, self.template_name, context)
        
        sn_object = SerialNumber()

        current_url = self.request.resolver_match.url_name
        print (current_url)

        try:
            #Get Oracle Connection Config
            sp_params = db_obj.createparams(f"GET,AWS_DFMS_CONN")
            sp_result = db_obj.runstoredprocedure(db_conn, 'get_service_config_by_service_id', sp_params)

            if not sp_result:
                context.update(
                    {                
                        'viewTitle': viewTitle,
                        'errorMsg': "No Oracle Connection Config found."
                    }
                )
                return render(self.request, self.template_name, context)

            json_conn = json.loads(sp_result)

            db = OracleDB(json_conn['username'], json_conn['password'], json_conn['hostname'], json_conn['port'], json_conn['servicename'])

            # Connect to the Oracle database
            db.connect()
            # sys_refcursor output
            out_param1 = db.conn.cursor().var(cx_Oracle.CURSOR)
            out_param2 = db.conn.cursor() 

            # execute the function
            out_param2.callfunc('FN_GET_MC_CODE', out_param1, ['GET_SCAN_MODE'])
            data = out_param1.getvalue().fetchall()

            keys = ['scan_mode']
            
            scan_modes = list()
            for info in data:
                values = [str(info[i]).strip().upper() for i in range(len(info))]
                scan_mode = {key:value for key,value in zip(keys,values)}
                scan_modes.append(scan_mode)

            # sys_refcursor output
            out_param1 = db.conn.cursor().var(cx_Oracle.CURSOR)
            out_param2 = db.conn.cursor() 
            # execute the function
            out_param2.callfunc('FN_GET_MC_CODE', out_param1, ['GET_CATEGORY'])
            data = out_param1.getvalue().fetchall()

            keys = ['category']
            
            categories = list()
            for info in data:
                values = [str(info[i]).strip().upper() for i in range(len(info))]
                category = {key:value for key,value in zip(keys,values)}
                categories.append(category)

            if self.request.GET:
                if 'errorMsg' in self.request.GET:
                    error = self.request.GET['errorMsg']
                    context.update(
                        {               
                            'viewTitle': viewTitle,
                            'scanModes': scan_modes,
                            'categories': categories,
                            'errorMsg': error
                        }
                    )
                    sn_object.sadmin_log('ERROR', 'MC Code Tool', self.template_name, context, self.request, username)

                elif 'successMsg' in self.request.GET:
                    success = self.request.GET['successMsg']
                    context.update(
                        {               
                            'viewTitle': viewTitle,
                            'scanModes': scan_modes,
                            'categories': categories,
                            'successMsg': success
                        }
                    )
                    sn_object.sadmin_log('SUCCESS', 'MC Code Tool', self.template_name, context, self.request, username)
            else:
                context.update(
                    {               
                        'viewTitle': viewTitle,
                        'scanModes': scan_modes,
                        'categories': categories
                    }
                )
                sn_object.sadmin_log('SUCCESS', 'MC Code Tool', self.template_name, context, self.request, username)


        except Exception as e:
            db.close()
            context.update(
                {                
                    'viewTitle': viewTitle,
                    'errorMsg': e
                }
            )
            sn_object.sadmin_log('EXCEPTION', 'MC Code Tool', 'MCCodeToolView', viewTitle, e, username)

        return render(self.request, self.template_name, context)


def mc_code_new_tool(request):

    def post(request):
        viewTitle = 'MC Code - New'
        context = {}
        error = {}
        data = request.POST

        mc_code = data.get('new_mc_code')
        mc_desc = data.get('new_mc_desc')
        scan_mode = data.get('new_scan_mode')        
        category = data.get('new_category')
        scannable = data.get('scannable')
        username = request.user.username

        db = None
        db_obj = DataLayer()
        db_conn = db_obj.connect()    

        if db_conn is None:
            error = 'There is a problem with Database connection, Call IT'
            return HttpResponseRedirect(f"/tls/mc_code/new?errorMsg={error}")
        
        sn_object = SerialNumber()

        current_url = request.resolver_match.url_name
        print (current_url)

        try:
            #Get Oracle Connection Config
            sp_params = db_obj.createparams(f"GET,AWS_DFMS_CONN")
            sp_result = db_obj.runstoredprocedure(db_conn, 'get_service_config_by_service_id', sp_params)

            if not sp_result:
                context.update(
                    {                
                        'viewTitle': viewTitle,
                        'errorMsg': "No Oracle Connection Config found."
                    }
                )
                return render(request, 'mc_code/mc_code_new.html', context)
                # return HttpResponseRedirect(f"/tls/mc_code/new?errorMsg={error}")

            json_conn = json.loads(sp_result)

            db = OracleDB(json_conn['username'], json_conn['password'], json_conn['hostname'], json_conn['port'], json_conn['servicename'])

            # Connect to the Oracle database
            db.connect()
            # sys_refcursor output
            out_param1 = db.conn.cursor().var(cx_Oracle.STRING)

            # execute the procedure main
            db.execute_procedure('SP_MC_CODE_TOOL_42Q',['INSERT',mc_code,mc_desc,scan_mode,category,scannable,username,out_param1])

            if out_param1.values[0] != 'OK':
                error = out_param1.values[0]
                context.update(
                    {               
                        'viewTitle': viewTitle,
                        'errorMsg': out_param1.values[0]
                    }
                )
                sn_object.sadmin_log('FAIL', 'MC Code Tool', viewTitle, context, request, username)
                return HttpResponseRedirect(f"/tls/mc_code/new?errorMsg={error}")
            else:
                success = out_param1.values[0]
                context.update(
                    {               
                        'viewTitle': viewTitle,
                        'successMsg': out_param1.values[0]
                    }
                )
                sn_object.sadmin_log('SUCCESS', 'MC Code Tool', viewTitle, context, request, username)
                return HttpResponseRedirect(f"/tls/mc_code/new?successMsg={success}")

        except Exception as e:
            db.close()
            context.update(
                {                
                    'viewTitle': viewTitle,
                    'errorMsg': e
                }
            )
            sn_object.sadmin_log('EXCEPTION', 'MC Code Tool', 'MCCodeToolView', viewTitle, e, username)

        # return JsonResponse(result, safe=False, status=200)
        return render(request, 'mc_code/mc_code_new.html', context)

    
    if request.method == 'POST':
        return post(request)    
# 20220616 Added by Quan GDLAWS42Q - New MC Code Tool, END
