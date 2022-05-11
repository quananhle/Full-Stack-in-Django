## Creating database table with django model

![image](https://learnbatta.com/assets/images/django/django-model-table.png)

Django made creating the tables in the database very simple with its built-in ```ORM```. To create table in the database with django is to create a django model with all required fields and then create migrations and apply them.

![image](https://user-images.githubusercontent.com/35042430/167939997-395161e4-14db-4dcc-8082-cd5cfd582ac6.png)

With the above code we are creating the table named "```person```" with fields "```first_name```", "```last_name```" and "```address```". The equivallent "```SQL```" for above django model is

![image](https://user-images.githubusercontent.com/35042430/167940202-bbcaa39f-c202-47e7-84d9-f060e0c5031d.png)

As we know django comes with ORM(Object Relational Mapper) so, we do not need to write SQL queries to deal with the database. We write database queries in django and django ORM converts all these queries into equivalent SQL and performs the query on the database and returns the results.

In the above code we have imported the "```models```" module which contains the functionality related to database(i.e ORM). "```models.Model```" is a base class for all model classes in django application. Each model class represents a database table.

