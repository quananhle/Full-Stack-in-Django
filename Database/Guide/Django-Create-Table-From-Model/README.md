## Creating database table with django model

![image](https://learnbatta.com/assets/images/django/django-model-table.png)

Django made creating the tables in the database very simple with its built-in ```ORM```. To create table in the database with django is to create a django model with all required fields and then create migrations and apply them.

![image](https://user-images.githubusercontent.com/35042430/167939997-395161e4-14db-4dcc-8082-cd5cfd582ac6.png)

With the above code we are creating the table named "```person```" with fields "```first_name```", "```last_name```" and "```address```". The equivallent "```SQL```" for above django model is

![image](https://user-images.githubusercontent.com/35042430/167940202-bbcaa39f-c202-47e7-84d9-f060e0c5031d.png)

As we know django comes with ORM(Object Relational Mapper) so, we do not need to write SQL queries to deal with the database. We write database queries in django and django ORM converts all these queries into equivalent SQL and performs the query on the database and returns the results.

In the above code we have imported the "```models```" module which contains the functionality related to database(i.e ORM). "```models.Model```" is a base class for all model classes in django application. Each model class represents a database table.

### Create migrations for above django model

To include the app in our project, we need to add a reference to its configuration class in the ```INSTALLED_APPS``` setting. The ```StocksConfig``` class is in the ```stock/apps.py``` file, so its dotted path is ```'stock.apps.StocksConfig'```. Edit the ```mysite/settings.py``` file and add that dotted path to the ```INSTALLED_APPS``` setting. It’ll look like this:

```{Python}
mysite/settings.py
INSTALLED_APPS = [
    'stock.apps.StocksConfig',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]
```

![image](https://user-images.githubusercontent.com/35042430/167946460-27891bb5-05e1-472e-b9ba-7217b45fc23d.png)

Now Django knows to include the stock app. To create migrations for the django application we have to run the below command. Let’s run another command:

```{Shell}
python manage.py makemigrations <app name>
```

above command will create migrations for the model in the directory "```migrations```" under the application directory.

### Apply migrations to create table in the database

To create table in the database for our django application we have to apply above created models using below command

```{Shell}
python manage.py migrate <app name>
```

After running above command it creates the table in the database. To write django models we need to know the different fields provided by django to use correct field for the table.

![image](https://user-images.githubusercontent.com/35042430/167946032-14715c9f-8c35-4443-b4d3-722f46ad36cb.png)

