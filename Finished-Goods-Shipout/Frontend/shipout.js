var errorMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-danger" role="alert" style="max-width: 400px;">';
errorMessageModal += '<p class="mb-0" id="errorMsg"></p></div></div></div>';

var successMessageModal = '<div class="row justify-content-md-center"><div class="col-md-auto"><div class="alert alert-success" role="alert" style="max-width: 400px;">';
successMessageModal += '<p class="mb-0" id="successMsg"></p></div></div></div>';

var spo = {
    
    loadMaterialDocInfo: function () {
        var tkn = jQuery("[name=csrfmiddlewaretoken]").val();
        var document_id = document.getElementById("material_id").value;
        var profile = $('input#profile').val();
        var messageBlock = $("#errorMsgModal");

        console.log(profile, document_id, tkn);

        var messageBlock = $("#errorMsgModal");
        messageBlock.children().remove();

        $.ajax({
            type: 'POST',
            url: '/shp/wh/shipout/load_md/',
            data: {
                'doc_id': document_id,
                'profile': profile,
                'csrfmiddlewaretoken': tkn
            },
            dataType: 'json',
            success: function (response) {
                console.log(response);
                $("#shipout").attr("disabled", false);

                $('#sold_to').html('');
                $('#ship_to').html('');

                let md_detail_table = $("#tracking-table tbody");
                md_detail_table.children().remove();
                let md_pallet_detail = response.pallets_info_list;
                console.log('md_pallet_detail: ', md_pallet_detail);
                            
                let template;
                let counter = 1;
                for (let i = 0; i < md_pallet_detail.length; i++) {
                    template += "<tr>";
                    template += "<td>" + (counter++) + "</td>";
                    template += "<td>" + md_pallet_detail[i][0] + "</td>"; 
                    template += "<td>" + md_pallet_detail[i][1] + "</td>";
                    template += "<td>" + md_pallet_detail[i][2] + "</td>";
                    template += "<td>" + md_pallet_detail[i][3] + "</td>";
                    template += "</tr>";
                }
                md_detail_table.append(template);

                $('#total_pn_qty').html(response.total_pn_qty);
                $('#total_pallets').html(response.total_pallets);
                $('#sloc_from').html(response.sloc_from);
                $('#sloc_to').html(response.sloc_to);
                let soldto = response.customer_info[0][2] + '\n' + response.customer_info[0][3];
                $('#sold_to').html(soldto.toUpperCase());
                let shipto = response.customer_info[0][0] + '\n' + response.customer_info[0][1]; 
                $('#ship_to').html(shipto.toUpperCase());

                $("#shipout").attr("style", "display:block")

            },
            error: function (response) {
                console.log(response);
                var error = response["responseJSON"]["result"];
                console.log(error);
                messageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);
                $("#shipout").attr("disabled", true);
            }
        })
    },

    shipout: function () {
        var tkn = jQuery("[name=csrfmiddlewaretoken]").val();
        var document_id = document.getElementById("material_id").value;
        var profile = $('input#profile').val();
        var messageBlock = $("#errorMsgModal");

        var messageBlock = $("#errorMsgModal");
        messageBlock.children().remove();

        var file_path = "";
        var files;
        var error;

        if (document_id == null && document_id == '') {
            error = 'Please press ENTER key after type in Material Document to load its data.';
            console.log(error);
            messageBlock.append(errorMessageModal);
            $('#errorMsg').append(error);
            return;
        }

        $('#spinner').show();

        $.ajax({
            type: "POST",
            url: "/shp/wh/shipout/shipload/",
            data: {
                'doc_id': document_id,
                'profile': profile,
                'csrfmiddlewaretoken': tkn
            },
            dataType: 'json',
            success: function (response) {
                console.log("success");
                console.log(response);
                files = response.printresult.fileList;
                file_path = response.printresult.filesPath;
                files1 = response.printresultPacking.fileList;
                file_path1 = response.printresultPacking.filesPath;
                $('#spinner').hide();

                $("#shipout").attr("style", "display:none")

            },
            error: function (response) {
                console.log(response);
                $('#spinner').hide();
                error = response["responseJSON"]["result"];
                console.log(error);
                messageBlock.append(errorMessageModal);
                $('#errorMsg').append(error);
            },
            complete: function (response) {
                console.log("COMPLETED");
                $('#spinner').hide();
                if (error) {
                    console.log(response);
                }
                else {
                    console.log(files);
                    console.log(file_path);
                    let fullname

                    for (let z = 0; z < files.length; z++) {
                        fullname = file_path + files[z];
                        console.log(fullname);
                        window.open(fullname, "_blank");
                    }
                    for (let z = 0; z < files1.length; z++) {
                        fullname = file_path1 + files1[z];
                        console.log(fullname);
                        window.open(fullname, "_blank");
                    }
                    
                    window.location.href = "/shp/wh/shipout/";
                }
            }

        });

    }
}
