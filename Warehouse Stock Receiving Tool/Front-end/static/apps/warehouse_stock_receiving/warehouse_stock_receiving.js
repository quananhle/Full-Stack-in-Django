var errorMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-danger" role="alert" style="max-width: 1600px;">';
errorMessageModal += '<p class="mb-0" id="errorMsg"></p></div></div></div>';

var successMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success" role="alert" style="max-width: 1600px;">';
successMessageModal += '<p class="mb-0" id="successMsg"></p></div></div></div>';

var messageBlock = $("#msgModal");

$('#save').css('visibility','hidden');
// $('#spinner').css('visibility','hidden');
$('#csn_table').css('visibility','hidden');
$('#csn_input_area').css('visibility','hidden');


var security = jQuery("[name=csrfmiddlewaretoken]").val();

var mask_rules = new Array();
var seen = new Set();
var mask_rule = {};

var mask, csn, memo, mfg_pn, fxn_pn;
var values = new Array();
var csn_table = $("#csn_table");
var csn_table_body = $("#csn_table tbody");
var csn_table_tbody = $("#tbl_body");
var profile = $('#profile').val();

var count = 0;

$("#mfg_pn_input").keypress(function(event) {
    $('#errorMsgModal').css('visibility','hidden');
    $('#error-message').css('visibility','hidden');
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if (keycode == 13) {
        event.preventDefault();        
        ubs.loading_mfg_pn();
    }
});

$("#barcode_2d_input").keypress(function(event) {
    $('#errorMsgModal').css('visibility','hidden');
    $('#error-message').css('visibility','hidden');
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if (keycode == 13) {
        event.preventDefault();        
        ubs.validate_2D_mask_rule();
    }
});

$("#bs_csn_input").keypress(function(event) {
    $('#errorMsgModal').css('visibility','hidden');
    $('#error-message').css('visibility','hidden');
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if (keycode == 13) {
        event.preventDefault();        
        ubs.scan_csn();
    }
});

$('#save').on('click', function() {
    $('#errorMsgModal').css('visibility','hidden');
    $('#error-message').css('visibility','hidden');
    ubs.save();
});

var ubs = {

    loading_mfg_pn: () => {
        $('#msgModal').children().remove();
        $('#spinner').show();

        mfg_pn = $("#mfg_pn_input").val();
        if (!mfg_pn){
            display_error("Manufacture PN is Empty. Scan and Try Again!");
            hide_table();
            $('#hh_pn').html('&nbsp;');
            $('#fxn_pn').html('&nbsp;');
            $('#aws_pn').html('&nbsp;');
            $('#save').css('visibility','hidden');
            $('#csn_input_area').css('visibility','hidden');
            $('#spinner').hide();
            return;
        }

        $.ajax({
            type: 'POST',
            headers: {
                'X-CSRFToken': security },
            data: JSON.stringify({
                'For' : 'scan_pn',
                'mfg_pn_ip' : mfg_pn ,
                'profile': profile }),
            dataType: 'json',
            success: function (response) {
                mask_rules = [];
                memo = response.memo;

                if ('BARCODE_2D' in memo[mfg_pn]) {
                    for (var arr of response.memo[mfg_pn].BARCODE_2D) {
                        // console.log(arr) ;
                        mask_rules.push(arr) ;
                    }
                }
                if ('BARCODE_1D' in memo[mfg_pn]) {
                    for (var arr of response.memo[mfg_pn].BARCODE_1D) {
                        // console.log(arr) ;
                        mask_rules.push(arr) ;
                    }
                }

                $('#hh_pn').html(response.afbs_list.HH_MODEL_ID);
                $('#fxn_pn').html(response.afbs_list.FXN_MODEL_ID);
                $('#aws_pn').html(response.afbs_list.AWS_MODEL_ID);
                $('#save').css('visibility','visible');
                $('#csn_input_area').css('visibility','visible');
                $('#bs_csn_input').focus();
                display_table();
            },
            error: function (response) {
                $('#hh_pn').html('&nbsp;');
                $('#fxn_pn').html('&nbsp;');
                $('#aws_pn').html('&nbsp;');
                $('#save').css('visibility','hidden');
                $('#csn_input_area').css('visibility','hidden');
                hide_table();
                display_error(response["responseJSON"]["errorMsg"]);
            },
            complete: function () {
                $('#spinner').hide();
                $("#mfg_pn_input").val('');
                $("#bs_csn_input").focus();
            }
        })
    },

    scan_csn: () => {
        $('#msgModal').children().remove();
        $('#spinner').show();

        var csn_input = $("#bs_csn_input").val();
        if (!csn_input){
            display_error("Component SN is Empty. Scan and Try Again.");
            $('#spinner').hide();
            return;
        }
        if (count == 3){
            display_error("Cannot Scan More Than " + count + " Components At Once. Save Progress And Continue.");
            $("#bs_csn_input").val('');
            $('#spinner').hide();
            return;
        }

        let found = false;
        // for (let elements of mask_rules){
        //     csn = 'BARCODE_1D' in memo[mfg_pn] ? csn_input : csn_input.slice(parseInt(elements[4])-1, parseInt(elements[4]) + parseInt(elements[5])-1);
        //     console.log(csn + ' ' + elements);

        //     if (csn.match(elements[3])){
        //         found = true;
        //         mask_rule['CSN'] = csn;
        //         mask_rule['FOXCONN_PN'] = elements[0];
        //         mask_rule['AWS_PN'] = elements[1];
        //         mask_rule['HONHAI_PN'] = elements[2];
        //         mask_rule['MASK_RULE'] = elements[3] ;
        //         break;
        //     }
        // }

        if ('BARCODE_1D' in memo[mfg_pn]){
            for (let row of memo[mfg_pn]['BARCODE_1D']){
                csn = csn_input;
                if (row[3] && csn.match(row[3])){
                    // console.log(csn + ' ' + row[3]);
                    found = true;
                    mask_rule['CSN'] = csn;
                    mask_rule['FOXCONN_PN'] = row[0];
                    mask_rule['AWS_PN'] = row[1];
                    mask_rule['HONHAI_PN'] = row[2];
                    mask_rule['MASK_RULE'] = row[3] ;
                    break;
                }
            }
        }

        if (!found){
            if ('BARCODE_2D' in memo[mfg_pn]){
                for (let row of memo[mfg_pn]['BARCODE_2D']){
                    csn = csn_input.slice(parseInt(row[4])-1, parseInt(row[4]) + parseInt(row[5])-1);
                    // console.log(csn_input);
                    // console.log(csn);
                    if (row[3] && csn.match(row[3])){
                        console.log(csn + ' ' + row[3]);
                        found = true;
                        mask_rule['CSN'] = csn;
                        mask_rule['FOXCONN_PN'] = row[0];
                        mask_rule['AWS_PN'] = row[1];
                        mask_rule['HONHAI_PN'] = row[2];
                        mask_rule['MASK_RULE'] = row[3] ;
                        break;
                    }
                }
            }
        }

        if (!found){
            display_error("Invalid Component SN Input: Matching Mask Logic Failed. Contact IT or check WIP_S_PARTS_MASKS.");
            $("#bs_csn_input").val('');
            $('#spinner').hide();
            return;
        }
        if (seen.has(mask_rule['CSN'])){
            display_error("Component Is Already Scanned. Scan Another Component.");
            $("#bs_csn_input").val('');
            $('#spinner').hide();
            return;
        }

        $.ajax({
            type: 'POST',
            headers: {
                'X-CSRFToken': security
            },
            data: JSON.stringify({
                'For': 'scan_csn',
                'fxn_pn': mask_rule['FOXCONN_PN'], 
                'csn': csn,
                'mask_rules': mask_rules,
                'profile': profile
            }),
            dataType: 'json',
            success: function (response) {
                seen.add(mask_rule['CSN']);
                // If table is initialized
                if ($.fn.DataTable.isDataTable('#csn_table')){
                    // Destroy existing table
                    csn_table.DataTable().destroy();
                }

                let template;
                count++;
                template += "<tr>";
                template += "<td>" + mask_rule['CSN'] + "</td>";
                template += "<td>" + mask_rule['FOXCONN_PN'] + "</td>";
                template += "<td>" + mask_rule['AWS_PN'] + "</td>";
                template += "<td>" + mask_rule['HONHAI_PN'] + "</td>";
                // template += "<td><button type=\"button\" class=\"btn btn-icon-only btn-primary text-secondary delete-row\"><i class=\"fa fa-trash\"></i></button></td>";
                template += "<td><div style='display: flex; justify-content: center;'><button class='btn btn-danger fas fa-trash delete-row'></button></div></td>";
                template += "</tr>";
                csn_table_body.append(template);
                
                // Show 10 entries 
                csn_table.DataTable({pageLength: 10});
            },
            error: function (response) {
                display_error(response["responseJSON"]["errorMsg"]);
            },
            complete: function () {
                $('#spinner').hide();
                $("#bs_csn_input").val('');
                $("#bs_csn_input").focus();
            }
        });
    },

    save: () => {
        $('#msgModal').children().remove();

        if (count == 0){
            display_error("No Component To Upload.");
            $("#bs_csn_input").val('')
            return;
        }

        $('#spinner').show();
        let table = $("#csn_table").DataTable();
        table.rows().every(function() {
            let rowData = this.data();
            if (!rowData || !rowData[0] || !rowData[1] || !rowData[2] || !rowData[3]){
                display_error("A Component Is Missing Data. Check The Table Again.");
                return;
            }
            // Access the data from the row and add it to the array
            values.push({
                CSN: rowData[0],
                FOXCONN_PN: rowData[1],
                AWS_PN: rowData[2],
                HONHAI_PN: rowData[3]
            });
        });

        $.ajax({
            type: 'POST',
            headers: {
                'X-CSRFToken': security
            },
            data: JSON.stringify({
                'For': 'save',
                'values' : values,
                'profile': profile
            }),
            dataType: 'json',
            success: function (response) {
                display_success(response.success);
            },
            error: function (response) {
                display_error(response["responseJSON"]["errorMsg"]);
            },
            complete: function () {
                count = 0;
                values = [];
                reset_table();
                seen.clear();
                $('#spinner').hide();
                $("#bs_csn_input").val('');
            }
        });
    }
};


// Handle click on delete button
$("#csn_table tbody").on('click', '.delete-row', function() {
    let confirmDelete = confirm('Are you sure you want to remove this row?');
    if (confirmDelete) {
        count--;
        let row = $(this).closest('tr');
        let substrings = row[0].innerText.split('\t').filter(substring => substring !== '');
        if (seen.has(substrings[0])){
            seen.delete(substrings[0]);
        }
        // DataTable API to remove the row
        $("#csn_table").DataTable().row(row).remove().draw();
    }
});
function reset_table(){
    csn_table_body.children().remove();
    csn_table_tbody.children().remove();
    // Reset datatable every time new input entered
    csn_table.DataTable().clear();
    // If table is initialized
    if ($.fn.DataTable.isDataTable('#csn_table')){
        // Destroy existing table
        csn_table.DataTable().destroy();
    }
};
function display_table(){
    $(document).ready(function () {
        $('#csn_table').DataTable();
    });
    $('#csn_table').css('visibility','visible');
};
function hide_table(){
    $(document).ready(function () {
        $('#csn_table').DataTable().destroy();
    });
    $('#csn_table').css('visibility','hidden');
};
function display_error(message){
    messageBlock.children().remove();
    messageBlock.append(errorMessageModal);
    $('#errorMsg').append(message);
    $('.alert-danger').css('background-color', '#f8d7da');
};
function display_success(message){
    messageBlock.children().remove();
    messageBlock.append(successMessageModal);
    $('#successMsg').append(message);
    $('.alert-success').css('background-color', '#d4edda');
};
