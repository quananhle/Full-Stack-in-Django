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

By running makemigrations, you’re telling Django that you’ve made some changes to your models (in this case, you’ve made new ones) and that you’d like the changes to be stored as a migration.

Migrations are how Django stores changes to your models (and thus your database schema) - they’re files on disk. You can read the migration for your new model if you like; it’s the file polls/migrations/0001_initial.py. Don’t worry, you’re not expected to read them every time Django makes one, but they’re designed to be human-editable in case you want to manually tweak how Django changes things.

There’s a command that will run the migrations for you and manage your database schema automatically - that’s called migrate, and we’ll come to it in a moment - but first, let’s see what SQL that migration would run. The sqlmigrate command takes migration names and returns their SQL:

```{Shell}
python manage.py sqlmigrate stock 0001
```

![image](https://user-images.githubusercontent.com/35042430/167946883-966a05db-3aa5-4c19-a87d-5eb1c1778389.png)

```{SQL}
BEGIN;
--
-- Create model FinancialStatement
--
CREATE TABLE "stock_financialstatement" ("id" serial NOT NULL PRIMARY KEY, "question_text" varchar(200) NOT NULL, "pub_date" timestamp with time zone NOT NULL);
--
-- Create model StockMarket
--
CREATE TABLE "stock_stockmarket" ("salesorder_id" varchar(50) NOT NULL PRIMARY KEY, "plant_code" varchar(100) NOT NULL, "customer_shipto" varchar(100) NOT NULL, "customer_soldto" varchar(100) NOT NULL, "salesorder_type" varchar(255) NOT NULL, "customer_po" varchar(255) NOT NULL, "customer_name" varchar(255) NOT NULL, "customer_name_alt" varchar(255) NOT NULL, "ship_priority" varchar(100) NOT NULL, "sap_create_date" timestamp with time zone NULL, "sap_change_date" timestamp with time zone NULL, "customer_reference" varchar(255) NOT NULL, "completed_date" timestamp with time zone NULL, "completed" integer NULL, "ship_hold" integer NULL, "ship_cancelled" integer NULL, "purchase_order_date" timestamp with time zone NULL, "ship_date" timestamp with time zone NULL, "ship_method" varchar(255) NULL, "creator" varchar(100) NULL, "create_date" timestamp with time zone NULL, "last_update" timestamp with time zone NOT NULL, "last_update_by" varchar(50) NULL, "ship_to_street" varchar(255) NULL, "ship_to_city" varchar(255) NULL, "ship_to_region" varchar(255) NULL, "ship_to_country" varchar(255) NULL, "ship_to_zipcode" varchar(255) NULL, "incoterm" varchar(10) NULL, "bill_to_name" varchar(255) NULL, "bill_to_address" varchar(255) NULL, "bill_to_city" varchar(255) NULL, "bill_to_region" varchar(255) NULL, "bill_to_country" varchar(255) NULL, "bill_to_zipcode" varchar(255) NULL, "carrier" varchar(255) NULL, "ship_to_name" varchar(255) NULL, "service_level" varchar(255) NULL);
--
-- Create model Quote
--
CREATE TABLE "stock_quote" ("id" serial NOT NULL PRIMARY KEY, "choice_text" varchar(200) NOT NULL, "votes" integer NOT NULL, "question_id" integer NOT NULL);
CREATE INDEX "stock_stockmarket_salesorder_id_259874cf_like" ON "stock_stockmarket" ("salesorder_id" varchar_pattern_ops);
ALTER TABLE "stock_quote" ADD CONSTRAINT "stock_quote_question_id_293d9437_fk_stock_financialstatement_id" FOREIGN KEY ("question_id") REFERENCES "stock_financialstatement" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "stock_quote_question_id_293d9437" ON "stock_quote" ("question_id");
COMMIT;
```

Note the following:

- The exact output will vary depending on the database you are using. The example above is generated for PostgreSQL.
- Table names are automatically generated by combining the name of the app (stock) and the lowercase name of the model – quote, stockmarket, and financial statement. (You can override this behavior.)
- Primary keys (IDs) are added automatically. (You can override this, too.)
- By convention, Django appends __"_id"__ to the foreign key field name. (Yes, you can override this, as well.)
- The foreign key relationship is made explicit by a __FOREIGN KEY__ constraint. Don’t worry about the __DEFERRABLE__ parts; it’s telling PostgreSQL to not enforce the foreign key until the end of the transaction.
- It’s tailored to the database you’re using, so database-specific field types such as __auto_increment (MySQL)__, __serial (PostgreSQL)__, or __integer primary key autoincrement (SQLite)__ are handled for you automatically. Same goes for the quoting of field names – e.g., using double quotes or single quotes.
- The __sqlmigrate__ command doesn’t actually run the migration on your database - instead, it prints it to the screen so that you can see what SQL Django thinks is required. It’s useful for checking what Django is going to do or if you have database administrators who require SQL scripts for changes.
- If you’re interested, you can also run ```python manage.py check```; this checks for any problems in your project without making migrations or touching the database.

Now, run ```migrate``` again to create those model tables in your database:

![image](https://user-images.githubusercontent.com/35042430/167950582-99ebfa0b-00b3-4c64-9682-6088e0d25f3b.png)

