## Component Details Update

![image](https://user-images.githubusercontent.com/35042430/160862125-0f30e87e-2fa7-4e98-af8a-1981b0a8110d.png)

__Enter any value and press Update button. If passed validation (satisfied all conditions), successful message is displayed.__

__Otherwise, error message is displayed to inform user at which condition process was failed__
![image](https://user-images.githubusercontent.com/35042430/160862209-8f1a755f-cad2-44cd-9153-417ea20aa870.png)

![image](https://user-images.githubusercontent.com/35042430/160862892-63d3b007-c7cf-4f59-8731-190921078794.png)
![image](https://user-images.githubusercontent.com/35042430/160862910-57f976ec-c491-41bb-a0ba-41e1cf857fce.png)

__Models:__ instead of using ORM (object-relational mapper), application is getting data directly using database functions for validating, displaying, and formatting data, and database stored procedures for validating and updating data. The reason behind is for simple maintenances processes as IT and Engineer teams also have access to the database and can modify to the needs accordingly, while only SWE team can provide support in the application source code, and every update in the source code requires more resources.




