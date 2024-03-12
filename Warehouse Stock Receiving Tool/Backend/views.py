from email import message
from pickle import FALSE
from turtle import pos
from typing import Any
from venv import create
from django import http
from django.shortcuts import redirect, render
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import View, generic
import json 
from django.http import JsonResponse
from django.http import HttpResponseRedirect
from datetime import datetime, date
from django.http.response import HttpResponse

#=== LOCAL IMPORTS
from srv.database.db_actions import *
from srv.print.documents.print_asn import *
from tls.transfer.upload_catalogue import UploadCatalogue
from srv.print.label.print_label import *
from srv.sap.workorder.upload_cwo import *
from srv.sap.workorder.dismantle_wo import *
from mfg.wip_flow.sn_object import * 
from srv.print.documents.print_document import * # 20221209 Added by Ethan GDlAWSSPARE_UAT - CIMS_V_2.1.1, Hold Tool Update
from rest_framework.views import APIView
from collections import defaultdict
import re

# Added by Quan GDLAWSBS - Upload AFBS WH Tool, 01/26/2024, BEGIN
class UploadAFBSToolView(LoginRequiredMixin, View):
    template_name = 'upload_bs/upload_bs.html'

    def dispatch(self, request):
        if request.method == 'POST':
            post_data = dict(json.loads(request.body))
            if post_data.get('For'):
                if post_data.get('For') == 'scan_pn':
                    return self.scan_pn(post_data)
                elif post_data.get('For') == 'scan_csn':
                    return self.scan_csn(post_data)
                elif post_data.get('For') == 'save':
                    return self.save(post_data)
                else:
                    return self.get()
            return self.get()
        return self.get()


    def get(self):
        context = {}
        viewTitle = 'Receive AFBS'
        try:
            user_name = self.request.user
            db_obj = DataLayer()
            db_conn = db_obj.connect()
            if db_conn is None:
                context.update(
                    { 'errorMsg': 'There is a problem with CIMS Database connection, Call IT' } 
                ) 
                return render(self.request, self.template_name, context)

            sp_params = db_obj.createparams(f"GET,AWS_DFMS_CONN")
            sp_result = db_obj.runstoredprocedure(db_conn, 'get_service_config_by_service_id', sp_params)

            if not sp_result:
                context.update (
                    {'errorMsg':'There is a problem with getting Oracle Connection data'}
                )
                return JsonResponse(context, safe=False, status=400)

            json_conn = json.loads(sp_result)
            oracle_db_obj = OracleDB(json_conn['username'], json_conn['password'], json_conn['hostname'], json_conn['port'], json_conn['servicename'])
            oracle_db_obj.connect()

            out_param1 = oracle_db_obj.conn.cursor().var(cx_Oracle.CURSOR)
            out_param2 = oracle_db_obj.conn.cursor() 
            out_param2.callfunc('AFBS_UPLOAD_GET_FN', out_param1, ['GET_BS_CSN_TABLE_HEADER'])
            tbl_header = [col for col in out_param1.getvalue().fetchall()[0]]

            context.update ({
                'viewTitle' : viewTitle ,
                'tbl_header' : tbl_header ,
                'profile' : user_name,
            })
        except Exception as e:
            context.update({ 'errorMsg':  str(e)})
            return JsonResponse(context, safe=False, status=400)

        return render(self.request, self.template_name,context)

    def scan_pn(self, data):
        context = {}
        viewTitle = 'Scan BS CSN'
        try:
            input = data.get('mfg_pn_ip')
            db_obj = DataLayer()
            db_conn = db_obj.connect()
            if db_conn is None:
                context.update(
                    { 'errorMsg': 'There is a problem with CIMS Database connection, Call IT' } 
                ) 
                return render(self.request, self.template_name, context)

            sp_params = db_obj.createparams(f"GET,AWS_DFMS_CONN")
            sp_result = db_obj.runstoredprocedure(db_conn, 'get_service_config_by_service_id', sp_params)

            if not sp_result:
                context.update (
                    {'errorMsg':'There is a problem with getting Oracle Connection data'}
                )
                return JsonResponse(context, safe=False, status=400)

            json_conn = json.loads(sp_result)
            oracle_db_obj = OracleDB(json_conn['username'], json_conn['password'], json_conn['hostname'], json_conn['port'], json_conn['servicename'])
            oracle_db_obj.connect()

            out_param1 = oracle_db_obj.conn.cursor().var(cx_Oracle.CURSOR)
            out_param2 = oracle_db_obj.conn.cursor() 
            out_param2.callfunc('AFBS_UPLOAD_GET_FN', out_param1, ['|'.join(['GET_PN_DETAILS_BY_MFG_MODEL' , input])])
            d = out_param1.getvalue().fetchall()
            afbs = defaultdict(list)
            # No one can replace you if no one understands your code
            for v, k in zip([q.split('|')[0].strip() for e in d for q in e], [q.split('|')[1].strip() for e in d for q in e]):      
                afbs[k].append(v)
            if 'ERROR' in afbs:
                context.update({'errorMsg': afbs.get('ERROR')[0]})
                return JsonResponse(context, safe=False, status=400)
            memo = defaultdict(dict)
            memo[input].update(afbs)

            out_param1 = oracle_db_obj.conn.cursor().var(cx_Oracle.CURSOR)
            out_param2 = oracle_db_obj.conn.cursor() 
            out_param2.callfunc('AFBS_UPLOAD_GET_FN', out_param1, ['|'.join(['GET_MASK_RULES' , ','.join(afbs.get('FXN_MODEL_ID'))])])
            d = out_param1.getvalue().fetchall()
            if d and d[0][0] == 'ERROR':
                context.update({'errorMsg': 'No Specified Mask Logic Found for Manufacture PN {}. Contact IT or check WIP_S_PARTS_MASKS.'.format(input)})
                return JsonResponse(context, safe=False, status=400)
        
            mask_rules = defaultdict(list)
            # Again, no one can replace you if no one understands your code
            for b, r, i, l, m, a, h in d:
                mask_rules[b].append((m, a, h, r, i, l))
            memo[input].update(mask_rules)

            for key, val in afbs.items():
                for i in range(len(val)):
                    afbs[key][i] += '<br>'

            context.update ({'viewTitle' : viewTitle , 'afbs_list' : afbs , 'memo' : memo , 'mask_rules' : mask_rules})

        except Exception as e:
            context.update({ 'errorMsg':  str(e)})
            return JsonResponse(context, safe=False, status=400)
        return JsonResponse(context, safe=False, status=200)
    
    def scan_csn(self, data):
        context = {}
        try:
            # illegal_characters_rule = '[^a-zA-Z0-9\-]|[-]{2,}'
            db_obj = DataLayer()
            db_conn = db_obj.connect()
            if db_conn is None:
                context.update({ 'errorMsg': 'There is a problem with CIMS Database connection, Call IT' }) 
                return render(self.request, self.template_name, context)

            sp_params = db_obj.createparams(f"GET,AWS_DFMS_CONN")
            sp_result = db_obj.runstoredprocedure(db_conn, 'get_service_config_by_service_id', sp_params)

            if not sp_result:
                context.update ({'errorMsg':'There is a problem with getting Oracle Connection data'})
                return JsonResponse(context, safe=False, status=400)

            json_conn = json.loads(sp_result)
            oracle_db_obj = OracleDB(json_conn['username'], json_conn['password'], json_conn['hostname'], json_conn['port'], json_conn['servicename'])
            oracle_db_obj.connect()

            cursor = oracle_db_obj.conn.cursor() 
            cursor.execute(f"SELECT COUNT(1) FROM SHP_SB_WH WHERE COMPONENT_SN = '{data.get('csn')}' AND FXN_MODEL_ID = '{data.get('fxn_pn')}'")
            result = cursor.fetchall()[0][0]
            oracle_db_obj.conn.cursor().close()

            if result:
                context.update({'errorMsg' : f"Component '{data.get('csn')}' Already Scanned And Uploaded."})
                return JsonResponse(context, safe=False, status=400)

        except Exception as e:
            context.update({ 'errorMsg':  str(e)})
            return JsonResponse(context, safe=False, status=400)
        return JsonResponse(context, safe=False, status=200)

    def save(self, data):
        context = dict()
        viewTitle = 'Save BS' 
        try:
            sp_result = DataLayer().runstoredprocedure(DataLayer().connect(), 'get_service_config_by_service_id', DataLayer().createparams(f"GET,AWS_DFMS_CONN"))
            if not sp_result:
                context.update (
                    {'errorMsg':'Oracle confifuration is missing: AWS_DFMS_CONN'}
                )
                return JsonResponse(context, safe=False, status=400)
            
            oracle_db_obj = OracleDB(json.loads(sp_result)['username'], json.loads(sp_result)['password'], json.loads(sp_result)['hostname'], json.loads(sp_result)['port'], json.loads(sp_result)['servicename'])
            oracle_db_obj.connect()

            duplicated_csn = list()
            uploaded_count = 0
            for element in data.get('values'):
                # Logic for checking every entry not used at this moment
                if 1 == 1:
                    cursor = oracle_db_obj.conn.cursor() 
                    cursor.execute(f"SELECT COUNT(1) FROM SHP_SB_WH WHERE COMPONENT_SN = '{element.get('CSN')}' AND FXN_MODEL_ID = '{element.get('FOXCONN_PN')}'")
                    result = cursor.fetchall()[0][0]

                    if result:
                        duplicated_csn.append((element.get('CSN'), element.get('FOXCONN_PN')))
                        continue

                out_param = oracle_db_obj.conn.cursor().var(cx_Oracle.STRING)
                oracle_db_obj.execute_procedure('SHP_SB_WH_SP', [element['CSN'], element['FOXCONN_PN'], element['AWS_PN'], element['HONHAI_PN'], data.get('profile'), out_param])
                if str(out_param.getvalue()) != 'OK' :
                    context.update({ 'errorMsg':  str(out_param.getvalue())})
                    if oracle_db_obj:
                        oracle_db_obj.close()
                    return JsonResponse(context, safe=False, status=400)
                
                sp_result = DataLayer().runstoredprocedure(DataLayer().connect(), 'shp_bs_wh_save', ("SAVE", json.dumps({'COMPONENT_SN' : element['CSN'], 'FXN_MODEL_ID' : element['FOXCONN_PN'], 'AWS_MODEL_ID' : element['AWS_PN'], 'MFG_MODEL_ID' : element['HONHAI_PN']}), data.get('profile')))
                if sp_result:
                    context.update ({'errorMsg' : 'PostgreSQL DB Failed To Complete.'})
                    return JsonResponse(context, safe=False, status=400)
                
                uploaded_count += 1
            oracle_db_obj.conn.cursor().close()
            if duplicated_csn and uploaded_count:
                messages = [f"{uploaded_count} Components Uploaded Successfully. {len(duplicated_csn)} Components Failed To Upload Due To The Reason: Duplicate Record Found.<br>List of Failed Records Is As Below: <br>"]
                for values in duplicated_csn:
                    message = f"- CSN: {values[0]} of FXN PN: {values[1]} <br>"
                    messages.append(message)
                context.update ({'errorMsg' : messages})
                return JsonResponse(context, safe=False, status=400)

            context.update ({'viewTitle' : viewTitle, 'success' : 'Upload Successfully!'})
        except Exception as e:
            context.update({ 'errorMsg':  str(e)})
            return JsonResponse(context, safe=False, status=400)
        return JsonResponse(context, safe=False, status=200)
# Added by Quan GDLAWSBS - Upload AFBS WH Tool, 01/26/2024, END
