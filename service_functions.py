#=============================================Service Functions===================================================================#
def get_bt_data(self, print_type):
    if not print_type:
        self.error = 'Print Type cannot be empty/null.'
        return
    self.printType = print_type

    try:            
        labelConfigObject = LabelConfig.objects.filter(object_type=self.printType).values('label_id', 'body_qty', 'printer_id', 'printer_webservice')
        if not labelConfigObject:
            self.error = f"Entered print type: { print_type } was not found."
            return

    except LabelConfig.DoesNotExist:
        self.error.append = f"Entered print type: { print_type } was not found."
        return           

    for item in labelConfigObject:
        self.templateName = item.get('label_id')
        self.printerName = item.get('printer_id')
        self.printServiceUrl = item.get('printer_webservice')
        self.bodyQty = item.get('body_qty')

    if not self.templateName or not self.printerName or not self.printServiceUrl or not self.bodyQty:
        self.error = 'Label Config missing attributes'
        return

    print(self.templateName, self.printerName, self.printServiceUrl, self.bodyQty)

    return 

def get_data(self, object_value, transtype):
    if not object_value:
        self.error = 'Print Type cannot be empty/null.'
        return
    if not transtype:
        self.error = 'Print Transtype cannot be empty/null.'
        return

    self.transtype = transtype
    self.value = object_value

    try:
        params = self.database.createparams(f"{self.transtype},{self.value}")
        data_result = self.database.runfunction(self.database_conn, 'print_get_data_pack_pallet_fn', params)
    except Exception as e:
        self.error = str(e)
        return                

    self.header.update(
        {"printer_name": self.printerName,
        "template_name": self.templateName}
    )

    for item in data_result:
        if item[0] == 'HEADER':                
            if item[1] == 'variable_name':
                self.variableName = item[2]
            else:
                self.header.update({item[1]: item[2]})
        if item[0] == 'BODY':
            self.body.append(item[2])

    self.pageFrom = 1

    if not self.body:
        self.pageTo = 1
    else:            
        self.dataQty = len(self.body)

        self.pageTo = math.ceil(self.dataQty / self.bodyQty)                

        sn = {}
        sn_list = []
        x = 1

        for i in range(0, self.dataQty):
            sn.update({self.variableName + str(x): self.body[i]})
            if len(sn) == self.bodyQty or i == self.dataQty - 1:
                sn_list.append(sn.copy())
                x = 1
                sn.clear()
            else:
                x += 1                

    dataList = {}
    while self.pageFrom <= self.pageTo:
        self.header.update(
            {"pageFrom": self.pageFrom, "pageTo": self.pageTo}
        )
        if not self.body:
            dataList = self.header
        else:
            dataList = { **self.header, **sn_list[self.pageFrom - 1] }

        self.data.append(json.dumps(dataList.copy()))
        dataList.clear()

        self.pageFrom += 1


    for item in self.data:
        print(item)                   

    return
    
def set_print(self):
    statusCode = None
    responseText = None
    try:
        for item in self.data:
            wsPrintRequest = requests.post(self.printServiceUrl, data = item)
            statusCode = wsPrintRequest.status_code
            responseText = json.loads(wsPrintRequest.content.decode('utf-8-sig'))['Messages'][0]['Text']
            responseText = responseText.split('\r')[0]
            self.printResult.update({'status': statusCode, 'message': responseText})

    except Exception as e:
        self.error = str(e)
        return

    return

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
