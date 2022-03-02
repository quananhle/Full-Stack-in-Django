var errorMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-danger" role="alert" style="max-width: 400px;">';
errorMessageModal += '<p class="mb-0" id="errorMsg"></p></div></div></div>';

var successMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success" role="alert" style="max-width: 400px;">';
successMessageModal += '<p class="mb-0" id="successMsg"></p></div></div></div>';

var tkn = jQuery("[name=csrfmiddlewaretoken]").val();
var profile = $('input#profile').val();
var errorMessageBlock = $("#errorMsgModal");
var successMessageBlock = $("#successMsgModal");

var model_id = document.getElementById("model_id").value;

let model_manager_master_table = $("#tracking-master-table tbody");
let model_manager_data_table = $("#tracking-data_related-table tbody");

let form_model_manager_master_table = $("#form-tracking-master-table tbody");
let form_model_manager_data_table   = $("#form-tracking-data_related-table tbody");

var mm = {
    updateButton : function () {
        // get the values of input fields
        var keypart      = document.getElementById("inputKeypart").value;
        var mask         = document.getElementById("inputMaskRule").value;
        var catid        = document.getElementById("inputCategoryID").value;
        var esp_desc     = document.getElementById("inputSpanishDescription").value;
        var fracc_nico   = document.getElementById("inputFraccNico").value;
        var uom_value    = document.getElementById("inputUOMValue").value;
        var hst_usa      = document.getElementById("inputHstCode").value;
        var fracc_digits = document.getElementById("inputFraccDigits").value;
        var tech_desc    = document.getElementById("inputTechnicalDescription").value;

        var trans_type_master = 'UPDATE-MAIN';
        var trans_type_detail = 'UPDATE-DATA-RELATED';

        // reset message before next event
        errorMessageBlock.children().remove();
        successMessageBlock.children().remove();

        const list = [model_id, keypart, mask, catid, esp_desc, fracc_nico, uom_value, hst_usa, fracc_digits, tech_desc];

        $('#spinner').show();

        $.ajax({
            // send request to views
            type: 'POST',
            // look for the right function in views.py based on the path in urls.py
            url: '/mfg/wip/mo_manager/update/serialization',
            // send over data collected from front end to views.py
            data: {
                'model_id'           : model_id,
                'keypart'            : keypart,
                'mask_rule'          : mask,
                'category_id'        : catid,
                'spanish_description': esp_desc,
                'fracc_nico'         : fracc_nico,
                'uom_value'          : uom_value,
                'hst'                : hst_usa,
                'fracc_digits'       : fracc_digits,
                'technical_desc'     : tech_desc,
                'profile'            : profile,
                'trans_type_master'  : trans_type_master,
                'trans_type_detail'  : trans_type_detail,
                'csrfmiddlewaretoken': tkn            
            },
            dataType: 'json',
            success: function (response) {
                // reset values in both table
                form_model_manager_master_table.children().remove();
                form_model_manager_data_table.children().remove();
                
                // get the data from runfunction(db_conn,'mfg_model_manager_update_fn', sp_params)
                let object = response.mm_info;

                let master_template; let data_template;

                for (let i = 0; i < object.length; i++) {
                    master_template += "<tr>"; data_template += "<tr>";
                    master_template += "<td>" + object[i][0]  + "</td>";    // model id
                    master_template += "<td>" + object[i][1]  + "</td>";    // keypart
                    master_template += "<td>" + object[i][2]  + "</td>";    // mask rule
                    master_template += "<td>" + object[i][3]  + "</td>";    // category id
                    master_template += "<td>" + object[i][4]  + "</td>";    // plant code
                    master_template += "<td>" + object[i][5]  + "</td>";    // sap changed date
                    data_template   += "<td>" + object[i][6]  + "</td>";    // spanish description
                    data_template   += "<td>" + object[i][7]  + "</td>";    // fracc nico
                    data_template   += "<td>" + object[i][8]  + "</td>";    // uom value
                    data_template   += "<td>" + object[i][9]  + "</td>";    // hst code
                    data_template   += "<td>" + object[i][10] + "</td>";    // fracc digit
                    data_template   += "<td>" + object[i][11] + "</td>";    // technnical description
                    master_template += "</tr>"; data_template += "</tr>";   
                }
                form_model_manager_master_table.append(master_template);
                form_model_manager_data_table.append(data_template);

                $('#inputKeypart')             .attr("placeholder", object[0][1]).val('');
                $('#inputMaskRule')            .val('');               
                $('#inputCategoryID')          .val('');
                $('#inputSpanishDescription')  .val('');    
                $('#inputFraccNico')           .val('');    
                $('#inputUOMValue')            .val('');    
                $('#inputHstCode')             .val('');    
                $('#inputFraccDigits')         .val('');
                $('#inputTechnicalDescription').val('');

                // display success message
                $('#spinner').hide();
                $("#successMsgModal").append(successMessageModal);
                $('#successMsg').append("Updated Successfully");

            },
            error: function (response) {
                console.log(response);
                $("#successMsgModal").children().remove();
                var error = response["responseJSON"]["result"];
                console.log(error);
                errorMessageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);
                // clear input fields at failed.
                $('#inputKeypart')             .val('');
                $('#inputMaskRule')            .val('');
                $('#inputCategoryID')          .val('');
                $("#noInputPlantCode")         .val('');
                $("#noInputSAPChangedDate")    .val('');
                $('#inputSpanishDescription')  .val('');
                $('#inputFraccNico')           .val('');
                $('#inputUOMValue')            .val('');
                $('#inputHstCode')             .val('');
                $('#inputFraccDigits')         .val('');
                $('#inputTechnicalDescription').val('');
            },
            complete: function (response) {
                console.log("COMPLETED");
                $('#spinner').hide();
                console.log(response);          
            }
        })
    }
}
