# Component Details Update Feature

![image](https://user-images.githubusercontent.com/35042430/160862125-0f30e87e-2fa7-4e98-af8a-1981b0a8110d.png)

__Enter any value and press Update button. If passed validation (satisfied all conditions), successful message is displayed.__

__Otherwise, error message is displayed to inform user at which condition process was failed__
![image](https://user-images.githubusercontent.com/35042430/160862209-8f1a755f-cad2-44cd-9153-417ea20aa870.png)

## Architecture

![image](https://user-images.githubusercontent.com/35042430/160871143-9cadc838-c4bb-465d-be0b-75ec65829ca0.png)

![image](https://user-images.githubusercontent.com/35042430/160862892-63d3b007-c7cf-4f59-8731-190921078794.png)
![image](https://user-images.githubusercontent.com/35042430/160862910-57f976ec-c491-41bb-a0ba-41e1cf857fce.png)

__Models:__ instead of using ORM (object-relational mapper) feature provided by Django, application is getting data directly using database functions for validating, displaying, and formatting data, and database stored procedures for validating and updating data. The reason behind is for simple maintenances processes as IT and Engineer teams also have access to the database and can modify to the needs accordingly, while only SWE team can provide support in the application source code, and every update in the source code requires more resources.

## Designs

### Views:

__HTTP GET attributes__

![image](https://user-images.githubusercontent.com/35042430/160866633-19fea563-cec0-4f63-8b20-a3b0cd64f5a2.png)

![image](https://user-images.githubusercontent.com/35042430/160867823-a71ee59a-17e3-42e6-9d79-4657543a6f88.png)

Run database function to select data. Using the Django shortcut functions render() to render the template model_details.html and returns an HttpResponse object with that rendered result from database function to the client-end/browser.

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




