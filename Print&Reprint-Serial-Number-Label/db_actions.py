#srv.database.db_actions

from django.db import connection
from typing import Optional
import sys
import re


class DataLayer():
    def __init__(self):
        self.sp_error = None
        self.fn_error = None

    def connect(self):
        err_result = None
        try:
            db_connected = connection
        except Exception as error:
            err_result = str(error)
            print(err_result)
        finally:
            return db_connected

    def genparams(self, params, contains_str_list: Optional[bool] = False):
        e_count = params.count(',')
        if e_count != 0:
            if contains_str_list:
                formatted = re.split(",(?![^[]*\])", params)
                p_tuple = tuple(formatted)
                value = f"{p_tuple}"
            else:
                p_list = params.split(',')
                p_tuple = tuple(p_list)
                value = f"{p_tuple}"
        else:
            value = f"('{ params }')"
        return value

    def createparams(self, params):
        e_count = params.count(',')
        if e_count != 0:
            p_list = params.split(',')
            p_tuple = tuple(p_list)
            value = f"{p_tuple}"
        else:
            value = f"('{ params }')"
        return value

    def runstoredprocedure(self, conn, spname, tparams):
        value = None
        cursor = conn.cursor()

        try:
            if len(spname) == 0:
                raise Exception('Missing data layer name element')
            if len(tparams) == 0:
                raise Exception('Missing data layer elements')

            query = f"call {spname} {tparams}"
            # print(query)
            sp_result = cursor.execute(query)
            rows = cursor.fetchall()
            for row in rows:
                value = row[0]

            conn.commit()

            return value

        except Exception as inst:
            self.sp_error = str(inst)
            return self.sp_error

    def runfunction(self, conn, fname, tparams):
        results = None

        try:
            cursor = conn.cursor()

            if len(fname) == 0:
                raise Exception('Missing data layer name element')
            if len(tparams) == 0:
                raise Exception('Missing data layer elements')

            query = f"select * from {fname} {tparams}"

            cursor.execute(query)

            results = cursor.fetchall()

            cursor.close()

            return results

        except Exception as inst:
            self.fn_error = str(inst)
            return

    def getControlValue(self, conn, c_name):
        try:
            c_value = self.runfunction(conn, 'get_controlvalues', self.createparams(c_name))
            c_value = [x[0] for x in c_value]

        except Exception as inst:
            self.sp_error = str(inst)
            return

        return c_value
