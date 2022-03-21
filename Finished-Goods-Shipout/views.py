from django.shortcuts import render
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views import View, generic
from django.http import JsonResponse
import json

#=== LOCAL IMPORTS
from srv.database.db_actions import *
from srv.print.documents.print_commercial_wh import *
from srv.print.documents.print_packing_list_wh import *

# ================================================================================================================================================= #
# Warehouse Shipout
class WarehouseShipoutView (LoginRequiredMixin, generic.ListView):
    template_name = 'shipout_warehouse/shipout_warehouse.html'

    def get(self, *args, **kwargs):
        context = {}      
        viewTitle = 'Ship Out Warehouse'
        context.update({'viewTitle': viewTitle})
        db_obj = DataLayer()
        db_conn = db_obj.connect()    
        
        data = self.request.GET

        if db_conn is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            ) 
            return render(self.request, self.template_name, context)

        if 'errorMsg' in data:
            error = self.request.GET['errorMsg']
            if error:
                context.update(
                    { 'errorMsg': error }
                )

        context.update(
            { 
                'viewTitle': viewTitle
            }
        )

        return render(self.request, self.template_name, context)
    
    def post(self, *args, **kwargs):
        context = {}
        error = {}
        data = self.request.POST       
        viewTitle = 'Ship Out Warehouse'
        context.update({'viewTitle': viewTitle})      


        
        db_obj = DataLayer()
        db_conn = db_obj.connect()

        if db_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)

        if not 'doc_id' in data:
            context.update({'result': 'Missing Material Document Parameter'})
            return JsonResponse(context, safe=False, status=400)          

        material_id = data.get('doc_id')

        material_id = material_id.strip()

        if not material_id:
            context.update({'result': 'Missing Material Document Value'})
            return JsonResponse(context, safe=False, status=400)  
        
        
        sp_result = None
        sp_params = db_obj.createparams(f"SHIPOUT,{material_id}")
        sp_result = db_obj.runstoredprocedure(db_conn,'wh_md_status_validation_sp', sp_params)

        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)

        sp_params = db_obj.createparams(f"{material_id}")
        pallet_header_list = db_obj.runfunction(db_conn,'wh_shipout_get_pn_by_md_fn', sp_params)

        for item in pallet_header_list:
            total_pn_qty = item[0]
            total_pallets = item[1]

        pallet_detail_list = db_obj.runfunction(db_conn,'wh_shipout_get_sloc_by_md_fn', sp_params)
        
        sloc_from = ''
        sloc_to = ''
        for item in pallet_detail_list:
            sloc_from = item[0]
            sloc_to = item[1]        

        customer_info = db_obj.runfunction(db_conn,'wh_shipout_get_ship_sold_info_fn', sp_params)
        pallets_info_list = db_obj.runfunction(db_conn,'wh_shipout_get_pallet_by_md_fn', sp_params)    

        context.update ({
            'material_id' : material_id,
            'total_pn_qty' : total_pn_qty,
            'total_pallets' : total_pallets,
            'sloc_from' : sloc_from,
            'sloc_to' : sloc_to,
            'customer_info' : customer_info,
            'pallets_info_list' : pallets_info_list
        })

        return JsonResponse(context, safe=False)

def wh_shipout_finish(request):

    if request.method == 'POST':        
        material_id = None
        username = None
        error = {}
        context = {}
        filesList = []

        if not 'doc_id' in request.POST:
            error.update({'result':'Missing Material Document ID parameter'})
            return JsonResponse(error, safe=False, status=400)
        
        material_id = request.POST['doc_id']
        username = request.POST['profile']

        if not material_id:
            error.update({'result':'Missing Material Document ID.'})
            return JsonResponse(error, safe=False, status=400)

        if not username:
            error.update({'result':'Missing Username.'})
            return JsonResponse(error, safe=False, status=400)


        sp_result = None
        sp_params = DataLayer().createparams(f"SHIPOUT,{material_id}")
        sp_result = DataLayer().runstoredprocedure(DataLayer().connect(),'wh_md_status_validation_sp', sp_params)
        if sp_result:
            error.update({'result':sp_result})
            return JsonResponse(error, safe=False, status=400)    

        database = DataLayer()
        database_conn = database.connect()
        if database_conn is None:
            error.update({'result':'There is a problem with Database connection, Call IT'})
            return JsonResponse(error, safe=False, status=400)
        
        try:
            params = database.createparams(f"{material_id},{username}")
            shipoutResult = database.runstoredprocedure(database_conn, 'wh_shipout_finish_md_sp', params)
            if shipoutResult:
                error.update({'result':shipoutResult})
                return JsonResponse(error, safe=False, status=400)                        

        except Exception as e:
            error.update({'result':str(e)})
            return JsonResponse(error, safe=False, status=400)
        
        try:
            printCommercialObject = PrintCommercialInvoiceWh(material_id)
            printResult = printCommercialObject.write_to_template()
            print("Printing Commercial Invoice")
            print(printResult)
            context.update({'printresult': printResult})

            printPackingListObject = PrintPackingListWH(material_id)
            printResult = printPackingListObject.write_to_template()
            print("Printing packing list")
            print(printResult)
            context.update({'printresultPacking': printResult})

        except Exception as e:
            result = json.dumps({'result': str(e)})
            return JsonResponse(result, safe=False, status=400)			

        return JsonResponse(context, safe=False, status=200)

class MaterialDocumentStatus(LoginRequiredMixin, View):
    template_name = 'transfer/md_status.html'

    def get(self, *args, **kwargs):
        context = {}
        userId = None
        userName = None
        db_obj = DataLayer()
        db_conn = db_obj.connect()    
        viewTitle = 'Material Document Status'
        context.update({'viewTitle': viewTitle})

        if db_conn is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            ) 
            return render(self.request, self.template_name, context)

        current_url = self.request.resolver_match.url_name

        params = db_obj.createparams('GET_MD_ALL')
        fn_result = db_obj.runfunction(db_conn, 'wh_get_md_status_fn', params)

        if not fn_result:
            context.update({'errorMsg': "No Material Documents were found."})
            return render(self.request, self.template_name, context)

        print(fn_result)

        context.update(
            {                
                'viewTitle': viewTitle,
                'uploadList': fn_result
            }
        )

        return render(self.request, self.template_name, context)
