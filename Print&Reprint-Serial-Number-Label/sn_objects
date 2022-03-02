from srv.database.db_actions import *
from mfg.models import *
from django.http import JsonResponse 

import math
import random

class SerialNumberAudit():
    def sn_sort_audit(self, serial_number, station_id, profile):
        context = {}
        if DataLayer().connect() is None:
            context.update(
                { 'errorMsg': 'There is a problem with Database connection, Call IT' } 
            ) 
            return context

        if serial_number and station_id:
            params = DataLayer().createparams(f"{serial_number},{station_id}")
            pmdu_mfg_serial_number_info = DataLayer().runfunction(DataLayer().connect(),'pmdu_mfg_sort_sn_audit', params)
        else:
            raise Exception("Serial Number Or Station ID Cannot Be Empty.")
            
        for data in pmdu_mfg_serial_number_info:
            workorder_id = data[0]
            model_id     = data[1]
            rate         = int(data[2])
            total        = int(data[3])
            counter      = int(data[4])

        validated_sn_list = self.get_sn_validated_list(workorder_id)
        random.shuffle(validated_sn_list)

        if counter <= 0:
            # counter should be calculated in and retrieved from other class. If none of the serial numbers of a workorder scanned before, counter should not be 0.
            # In a rare case, if, simultaneously, counter == 0, and none of the serial numbers of the workorder scanned before, len(validated_sn_list) == total
            if counter == 0 and len(validated_sn_list) == total:
                counter = self.get_num_to_send_to_ooba(rate, total)
                random_list = [validated_sn_list[i] for i in range(counter)]
                self.update_counter_sn_list(workorder_id, serial_number, random_list, profile)
            return False
        else:
            random_list = [validated_sn_list[i] for i in range(counter)]
            self.update_counter_sn_list(workorder_id, serial_number, random_list, profile)

    def get_sn_validated_list(self, workorder_id):
        params = DataLayer().createparams(f"{workorder_id}")
        validated_sn_list = DataLayer().runfunction(DataLayer().connect(),'pmdu_mfg_get_validated_sn_list', params)
        return [serial_number[0] for serial_number in validated_sn_list]

    def get_num_to_send_to_ooba(rate, total):
        if (rate * total / 100) < 1:
            pick = 1
        elif (rate * total % 100) != 0:
            pick = math.ceil(rate * total / 100)
        else:
            pick = int(rate * total / 100)
        return pick    

    def update_counter_sn_list(self, workorder_id, serial_number, random_list, profile):
        error = {}
        if serial_number in random_list:
            params = DataLayer().createparams(f"{'UPDATE-COUNTER'},{workorder_id},{serial_number},{profile}")
            sp_result = DataLayer().runstoredprocedure(DataLayer().connect, 'pmdu_mfg_sort_sn_audit_sp', params)
            if sp_result:
                error.update({'result' : sp_result})
                return JsonResponse(error, safe=False, status=400)             
            return False
        else: 
            params = DataLayer().createparams(f"{'UPDATE-VALIDATED-SN-LIST-ONLY'},{serial_number},{profile}")
            sp_result = DataLayer().runstoredprocedure(DataLayer().connect(), 'pmdu_mfg_sort_sn_audit_sp', params)
            if sp_result:
                error.update({'result' : sp_result})
                return JsonResponse(error, safe=False, status=400)          
            return True    

class SerialNumber():
    def __init__(self):
        self.context = {}
        self.fn_error = None

    def sadmin_log(self, log_type=None, log_event=None, log_value_additional=None, log_value=None, log_message=None, log_by=None):
        params = DataLayer().createparams(f"{log_type},{log_event},{log_value_additional},{log_value},{log_message},{log_by}")
        sp_result = DataLayer().runstoredprocedure(DataLayer().connect(), 'sadmin_log', params)
        return sp_result
