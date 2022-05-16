var errorMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-danger" role="alert" style="max-width: 400px;">';
errorMessageModal += '<p class="mb-0" id="errorMsg"></p></div></div></div>';

var successMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success" role="alert" style="max-width: 400px;">';
successMessageModal += '<p class="mb-0" id="successMsg"></p></div></div></div>';

var message = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success" role="alert" style="max-width: 400px;">';
message += '<p class="mb-0" id="msg"></p></div></div></div>';

var tkn = jQuery("[name=csrfmiddlewaretoken]").val();
var profile = $('input#profile').val();
var errorMessageBlock = $("#errorMsgModal");
var successMessageBlock = $("#successMsgModal");
var messageBlock = $("#msgModal");
var title = $("#title");
var selected_data; var viewTitle; var woType; var modelID; var objectType; var orderType;
$('#wo_input').focus();

var psl = {
    loadData: function () {
        var workorder_id = document.getElementById("wo_input").value;
        record_workorder_id = workorder_id;

        $('#spinner_left').show();

        var serial_number_list_table         = $("#serial_number_list_table");
        var serial_number_list_table_body    = $("#serial_number_list_table tbody");
        var print_status_tracking_table_body = $("#serial_number_list_table_tbody");

        messageBlock.children().remove();

        $.ajax({
            type: 'POST',
            url: '/lrm/print-sn/',
            data: {
                'workorder_id': workorder_id,
                'profile': profile,
                'csrfmiddlewaretoken': tkn
            },
            dataType: 'json',
            success: function (response) {
                // disable all input fields
                $("input").prop('disabled', true);
                serial_number_list_table_body.children().remove();
                print_status_tracking_table_body.children().remove();
                // Reset datatable every time new input entered
                serial_number_list_table.DataTable().clear();
                // // Hide button every time new input entered
                // $('#print_button').hide();

                // If table is initialized
                if ($.fn.DataTable.isDataTable('#serial_number_list_table')){
                    // Destroy existing table
                    serial_number_list_table.DataTable().destroy();
                }

                // get the data from runfunction(db_conn,'lrm_get_wo_info', sp_params)
                let object_dict = response.workorder_info;
                let serial_number_list = response.serial_number_list;      
                
                viewTitle = response.viewTitle;
                modelID = response.skuno;
                woType = object_dict['production_version'];
                objectType = object_dict['object_type'];
                orderType = object_dict['order_type'];

                $('#workorder_type_header' ).html(orderType);

                $('#status_card' ).html(object_dict['status_id']);
                $('#qty_card'    ).html(object_dict['target_qty']);
                $('#sku_card'    ).html(object_dict['skuno']);
                $('#wo_type_card').html(object_dict['production_version']);
                $('#sn_from_card').html(object_dict['sn_from']);
                $('#sn_to_card'  ).html(object_dict['sn_to']);
        
                let template; let counter = 1;
                for (let i = 0; i < serial_number_list.length; i++) {
                    template += "<tr>";
                    template += "<td>" + (counter++) + "</td>";
                    template += "<td>" + serial_number_list[i][0] + "</td>"; 
                    template += "</tr>";
                }
                serial_number_list_table_body.append(template);

                $("#print_button").css("background-color","lightgreen");
                $("#print_all_button").css("background-color","green");
                $('#print_button').show();
                $('#print_all_button').show();
                $('#reset_button').show();
                $("#print_all_button").focus();

                messageBlock.append(successMessageModal);
                $('#successMsg').append("Success");

                let table = serial_number_list_table.DataTable({
                    // Show only 5 entries instead of 10 as default
                    pageLength: 5,
                    // Allow select single entry only
                    select: {
                        style: 'single',
                        // toggleable: false
                    },
                });

                serial_number_list_table_body.on( 'click', 'tr', function () {
                    /* Add a click handler to the rows - this could be used as a callback */
                    /* Highlighted row styled in tr.row_selected in css */
                    $("#serial_number_list_table tbody tr").removeClass('row_selected');		
                    $(this).addClass('row_selected');
                    // Get data of selected row
                    selected_data = table.row( this ).data();
                    
                    messageBlock.children().remove();
                    messageBlock.append(message);
                    $('#msg').append("Selected Serial Number: No." + selected_data[0] + " - " + selected_data[1]);

                    $("#print_button").focus();
                    $("#print_button").css("background-color","green");
                    $("#print_all_button").css("background-color","lightgreen");
                });
            },
            error: function (response) {
                console.log(response);
                var error = response["responseJSON"]["result"];
                console.log(error);
                messageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);

                $("input").prop('disabled', false);
                $("#form")[0].reset();

                $('#status_card' ).html('&nbsp');
                $('#qty_card'    ).html('&nbsp');
                $('#sku_card'    ).html('&nbsp');
                $('#wo_type_card').html('&nbsp');
                $('#sn_from_card').html('&nbsp');
                $('#sn_to_card'  ).html('&nbsp');
            },
            complete: function () {
                console.log("COMPLETED");
                $('#spinner_left').hide();
            }
        })
    },

    print: function () {
        var workorder_id = document.getElementById("wo_input").value;
        messageBlock.children().remove();
        
        if (selected_data == '' || selected_data == null || selected_data == undefined) {
            messageBlock.append(errorMessageModal);
            $('#errorMsg').append("Please select a serial number from table below for single label generating.");
            return;
        }
        else {
            messageBlock.append(message);
            $('#msg').append("Generating label for SN: ", selected_data[1]);
            title.html(viewTitle + " <strong>" + selected_data[1] + "</strong>");
        }

        $('#spinner_right').show();
        var error;
        
        $.ajax({
            type: "POST",
            url: "/lrm/print-sn/label",
            data: {
                'workorder_id'       : workorder_id,
                'serial_number'      : selected_data[1],
                'workorder_type'     : woType,
                'skuno'              : modelID,
                'profile'            : profile,
                'object_type'        : objectType,
                'order_type'         : orderType,
                'csrfmiddlewaretoken': tkn
            },
            dataType: 'json',
            success: function (response) {
                let result = response["print_response"]["result"];
                let print_status_tracking_table_body = $("#print_status_tracking_table tbody");
                let log_message = response["print_response"]["log_message"]
                let template;
                /** 
                 * 
                 * Count the number of columns of table
                 * let num_columns = document.getElementById('print_status_tracking_table').rows[0].cells.length;
                 * 
                 **/

                 if (result == 'PASS') {
                    template += "<tr>";
                    template += "<td>" + response.serial_number + "</td>";
                    template += "<td>" + ("Label for SN: " +  selected_data[1] + " generated.") + "</td>"; 
                    template += "</tr>";
                    messageBlock.children().remove();
                    messageBlock.append(successMessageModal);
                    $('#successMsg').append("Label Generated Successfully.");
                }
                if (result == 'FAIL') {
                    template += "<tr>";
                    template += "<td>" + response.serial_number + "</td>";
                    template += "<td>" + log_message + "</td>"; 
                    template += "</tr>";
                    messageBlock.children().remove();
                    messageBlock.append(errorMessageModal);
                    $('#errorMsg').append('Print Failed. Check the log message below for more details.');
                }
                print_status_tracking_table_body.prepend(template);
                /**                
                 * $("#print_status_tracking_table").DataTable({
                 *      // Show only 5 entries instead of 10 as default
                 *      pageLength: 5,
                 *      "bDestroy": true
                 * });   
                 */
            },
            error: function (response) {
                error = 'Print Failed. Check the log message below for more details';
                log = response["responseJSON"]["log_message"];
                messageBlock.children().remove();
                messageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);
            },
            complete: function (response) {
                console.log("COMPLETED");
                $('#spinner_right').hide();
                $("#reset_button").focus();
            }
        });
    },
    printAll: function () {
        var workorder_id = document.getElementById("wo_input").value;

        messageBlock.children().remove();
        messageBlock.append(message);
        $('#msg').append("Generating all SN labels of WO " + workorder_id);

        $('#spinner_right').show();
        var error;
        
        $.ajax({
            type: "POST",
            url: "/lrm/print-sn/all-label",
            data: {
                'workorder_id'       : workorder_id,
                'workorder_type'     : woType,
                'skuno'              : modelID,
                'profile'            : profile,
                'object_type'        : objectType,
                'order_type'         : orderType,
                'csrfmiddlewaretoken': tkn
            },
            dataType: 'json',
            success: function (response) {
                let serial_number_list = response['serial_number_list'];
                let result = response["print_response"]["result"];
                let log_message = response["print_response"]["log_message"]
                let print_status_tracking_table_body = $("#print_status_tracking_table tbody");
                let template;

                /** 
                 * 
                 * Count the number of columns of table
                 * let num_columns = document.getElementById('print_status_tracking_table').rows[0].cells.length;
                 * 
                 **/

                for (let i = 0; i < serial_number_list.length; i++) {
                    if (result == 'PASS') {
                        template += "<tr>";
                        template += "<td>" + serial_number_list[i][0] + "</td>";
                        template += "<td>" + ("Label for SN: " +  serial_number_list[i][0] + " generated.") + "</td>"; 
                        template += "</tr>";
                        messageBlock.children().remove();
                        messageBlock.append(successMessageModal);
                        $('#successMsg').append("All Labels Generated Successfully.");
                    }
                    if (result == 'FAIL') {
                        template += "<tr>";
                        template += "<td>" + serial_number_list[i][0] + "</td>";
                        template += "<td>" + log_message + "</td>"; 
                        template += "</tr>";
                        messageBlock.children().remove();
                        messageBlock.append(errorMessageModal);
                        $('#errorMsg').append('Print Failed. Check the log message below for more details.');
                    }
                }
                print_status_tracking_table_body.prepend(template);
                /**                
                 * $("#print_status_tracking_table").DataTable({
                 *      // Show only 5 entries instead of 10 as default
                 *      pageLength: 5,
                 *      "bDestroy": true
                 * });   
                 */
            },
            error: function (response) {
                error = 'Print Failed. Check the log message below for more details';
                log = response["responseJSON"]["log_message"];
                messageBlock.children().remove();
                messageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);
            },
            complete: function (response) {
                console.log("COMPLETED");
                $('#spinner_right').hide();
                $("#reset_button").focus();
            }
        });
    },
    reset: function(){
        location.reload();
    }
}
