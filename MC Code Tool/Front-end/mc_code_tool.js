var errorMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-danger shadow-soft" role="alert" style="background-color:#a91e2c; color:#fff; display: table;">';
errorMessageModal += '<p class="mb-0" id="errorMsg"></p></div></div></div>';

var successMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success shadow-soft" role="alert" style="background-color:#18634b; color:#fff; display: table;">';
successMessageModal += '<p class="mb-0" id="successMsg"></p></div></div></div>';

var message = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success shadow-soft" role="alert" style="background-color:#18634b; color:#fff max-width: 450px;">';
message += '<p class="mb-0" id="msg"></p></div></div></div>';

var mcc = {
    updateButton : function () {
        // get the values of input fields
        var keypart      = document.getElementById("inputKeypart").value;
        var mask         = document.getElementById("inputMaskRule").value;
        var catid        = document.getElementById("inputCategoryID").value;
        var code         = document.getElementById("inputCode").value;
        var esp_desc     = document.getElementById("inputSpanishDescription").value;
        var fracc_nico   = document.getElementById("inputFraccNico").value;
        var uom_value    = document.getElementById("inputUOMValue").value;
        var hst_usa      = document.getElementById("inputHstCode").value;
        var fracc_digits = document.getElementById("inputFraccDigits").value;
        var tech_desc    = document.getElementById("inputTechnicalDescription").value;
        var customer_rev    = document.getElementById("inputCustomerRevision").value;  //  Added by Nhat.Do GDLMECH-10202022 - Add customer revision  

        var trans_type_master = 'UPDATE-MAIN';
        var trans_type_detail = 'UPDATE-DATA-RELATED';

        // reset message before next event
        errorMessageBlock.children().remove();
        successMessageBlock.children().remove();

        const list = [model_id, keypart, mask, code, catid, esp_desc, fracc_nico, uom_value, hst_usa, fracc_digits, tech_desc];

        $('#spinner').show();
        var pageURL = $(location).attr("href");
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
                'code'               : code,
                'category_id'        : catid,
                'spanish_description': esp_desc,
                'fracc_nico'         : fracc_nico,
                'uom_value'          : uom_value,
                'hst'                : hst_usa,
                'fracc_digits'       : fracc_digits,
                'technical_desc'     : tech_desc,
                'customer_rev'       : customer_rev,
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
                    data_template   += "<td>" + object [i][12] + "</td>";    //  Added by Nhat.Do GDLMECH-10202022 - Add customer revision  
                    master_template += "</tr>"; data_template += "</tr>";   
                }
                form_model_manager_master_table.append(master_template);
                form_model_manager_data_table.append(data_template);

                // $('#inputKeypart')             .attr("placeholder", object[0][1]).val('');
                // $('#inputMaskRule')            .val('');               
                // $('#inputCategoryID')          .val('');
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


                window.location.href = pageURL;

            },
            error: function (response) {
                console.log(response);
                $("#successMsgModal").children().remove();
                var error = response["responseJSON"]["result"];
                console.log(error);
                errorMessageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);
                // clear input fields at failed.
                // $('#inputKeypart')             .val('');
                // $('#inputMaskRule')            .val('');
                // $('#inputCategoryID')          .val('');
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
};

$( "#createMC" ).click(function(e) {            

    let errmsg = ''
    let starMask = parseInt($('#createMC-start').val())
    let endMask = parseInt($('#createMC-end').val())
    let prefixMask = $('#createMC-prefix').val()
    let lengthMask = parseInt($('#createMC-length').val())

    let prefixLength = prefixMask.length

    if (starMask <= 0){  
        errmsg = 'Start Mask cannot be less than 0'      
        display_error(errmsg)
        return
    }
    if (endMask <= 0){        
        errmsg = 'End Mask cannot be less than 0'      
        display_error(errmsg)
        return
    }
    if (lengthMask <= 0){        
        errmsg = 'Length Mask cannot be less than 0'      
        display_error(errmsg)
        return
    }
    if (prefixLength <= 0){        
        errmsg = 'Prefix Mask cannot be less than 0'      
        display_error(errmsg)
        return
    }

    if (prefixLength != endMask){        
        errmsg = 'Prefix Length and End Length does not match.'      
        display_error(errmsg)
        return
    }
    if (lengthMask <= endMask){
        errmsg = 'Mask Length cannot be lower or equal than End Mask'      
        display_error(errmsg)   
        return
    }
    

    mask_rule = $('#maskRule-start').val() + '|' + $('#maskRule-end').val() + '|' + $('#maskRule-prefix').val() + '|' + $('#maskRule-length').val()

    $('#inputMaskRule').val(mask_rule)
    $("#attributeModal").modal('hide');
    // save_attribute(attribute_name, csn_generate, print_label, user_input, sequential_input, mask_validation, mask_rule, attr_type, saved_attribute);
});
