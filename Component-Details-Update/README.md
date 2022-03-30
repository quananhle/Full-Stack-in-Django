# Component Details Update Feature

![image](https://user-images.githubusercontent.com/35042430/160862125-0f30e87e-2fa7-4e98-af8a-1981b0a8110d.png)

__Enter any value and press Update button. If passed validation (satisfied all conditions), successful message is displayed.__

__Otherwise, error message is displayed to inform user at which condition process was failed__
![image](https://user-images.githubusercontent.com/35042430/160862209-8f1a755f-cad2-44cd-9153-417ea20aa870.png)

## Architecture

![image](https://user-images.githubusercontent.com/35042430/160871143-9cadc838-c4bb-465d-be0b-75ec65829ca0.png)

![image](https://user-images.githubusercontent.com/35042430/160862892-63d3b007-c7cf-4f59-8731-190921078794.png)
![image](https://user-images.githubusercontent.com/35042430/160862910-57f976ec-c491-41bb-a0ba-41e1cf857fce.png)

__Models:__ instead of using ```ORM (object-relational mapper)``` feature provided by Django, application is getting data directly using database functions for validating, displaying, and formatting data, and database stored procedures for validating and updating data. The reason behind is for simple maintenances processes as IT and Engineer teams also have access to the database and can modify to the needs accordingly, while only SWE team can provide support in the application source code, and every update in the source code requires more resources.

## Designs

### URLs:

![image](https://user-images.githubusercontent.com/35042430/160872973-5dd5764a-2db3-4451-a72d-b27ea33102e6.png)

### Views:

__HTTP GET attributes__

![image](https://user-images.githubusercontent.com/35042430/160866633-19fea563-cec0-4f63-8b20-a3b0cd64f5a2.png)

![image](https://user-images.githubusercontent.com/35042430/160867823-a71ee59a-17e3-42e6-9d79-4657543a6f88.png)

Run database function to select data. Using the Django shortcut functions ```render()``` to render the template model_details.html and returns an ```HttpResponse``` object with that rendered result from database function to the [template](https://github.com/Quananhle/Full-Stack-in-Django/blob/main/Component-Details-Update/Frontend/model_detail.html).

```{SQL}
CREATE OR REPLACE FUNCTION public.mfg_model_manager_update_fn(v_model_id text)
 RETURNS TABLE(t_model_id character varying, t_keypart character varying, t_mask_rule character varying, t_category_id character varying, t_plant_code character varying, t_sap_changed_date character varying, t_spanish_desc character varying, t_fracc_nico character varying, t_uom_value character varying, t_hst_code character varying, t_fracc_digits character varying, t_technical_desc character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN QUERY
			SELECT a.model_id , CAST(a.keypart AS VARCHAR(50)), a.mask_rule, a.category_id , a.plant_code , CAST(c.sap_change AS VARCHAR(50)), 
				   b.spanish_description , b.fracc_nico , b.uom_value , b.hst_usa, b.fracc_digits , b.technical_description 
			FROM mfg_materialmaster a 
			INNER JOIN mfg_materialdatarelated b ON a.model_id = b.model_id
			INNER JOIN (SELECT model_id, TO_CHAR(sap_change_date, 'YYYY-MM-DD') || ' ' || TO_CHAR(sap_change_time, 'HH:MM:SS') sap_change FROM mfg_materialmaster) c ON a.model_id = c.model_id
			WHERE a.model_id = v_model_id;
	END;
$function$;
```

__HTTP POST attributes__

![image](https://user-images.githubusercontent.com/35042430/160872652-8aab1011-1632-4b8c-b3c3-94188b7ba58e.png)

![image](https://user-images.githubusercontent.com/35042430/160873640-b6a00f5e-62a9-4ed9-90cf-011789cf36d9.png)

Run database stored procedure [mfg_material_details_update_sp](https://github.com/Quananhle/Full-Stack-in-Django/blob/main/Database/Stored-Procedure/mfg_material_details_update_sp.sql) to update data. And then run database function [mfg_model_manager_update_fn](https://github.com/Quananhle/Full-Stack-in-Django/blob/main/Database/Function/mfg_model_manager_update_fn.sql) to select data again to display the updating results.  

---

![image](https://user-images.githubusercontent.com/35042430/160875096-3b9dc7a6-af09-446d-9c74-f96fd7d0f327.png)

Return JSON serialized response to the [template](https://github.com/Quananhle/Full-Stack-in-Django/blob/main/Component-Details-Update/Frontend/model_detail.html).

### Templates:

![image](https://user-images.githubusercontent.com/35042430/160882120-e1c5c826-086a-4413-ba80-748e41814840.png)

Getting requests from client

--- 

![image](https://user-images.githubusercontent.com/35042430/160882290-e06c8b20-432c-4a2f-b6ff-ae7e78e4113a.png)

Using AJAX to send data to Views in POST request

---

![image](https://user-images.githubusercontent.com/35042430/160883588-eb649ffc-f54d-4576-9225-2991082c324f.png)

Using AJAX to fetch the JSON response received from Views
