## Create New Database

The syntax to create database in PostgreSQL is

```{Shell}
CREATE DATABASE databasename
```

Let’s learn setting up PostgreSQL and how to create database in PostgreSQL command line and the GUI

### PSQL Create Database Command Line (SQL Shell)

__Step 1)__ Open the SQL Shell

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC1.png)

__Step 2)__ Press enter five times to connect to the DB

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC2.png)

__Step 3)__ Enter the command

```{Shell}
CREATE DATABASE guru99;
```

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC3.png)

__Step 4)___ Enter command ```\l``` to get a list of all databases

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC4.png)

__Step 5)__ To connect to a Database use PostgreSQL database command

```{Shell}
\c guru99
```

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC5.png)

Prompt changes to ```guru99``` which signifies that we are connected to database ```guru99``` and can perform operations like create table, trigger, execute SQL on it.

![image](https://user-images.githubusercontent.com/35042430/167919026-f60239a6-525c-4f96-8401-84bb9ad30bff.png)

### PostgreSQL Create Database using pgAdmin 4

__Step 1)__ In the Object Tree, right click and select create a database to Postgres create database

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC6.png)

__Step 2)__ In the pop-up,

1. Enter Database Name
2. Comment if any database – optional
3. Click Save

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC7.png)

In this example, we entered ```quan_le``` as the name of the new database and postgres as the owner. Select the Definition tab to set the properties for the database:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/PostgreSQL-Create-Database-pgAdmin-Step-3.png)

In the ```Definition``` tab, you can select the encoding, choose a template, tablespace, collation, character type, and connection limit.

The ```Security``` tab allows you to define security labels and assign privileges. The ```Privileges``` tab allows you to assign privileges to a role.

![image](https://user-images.githubusercontent.com/35042430/167922652-4f70daa6-7850-4055-a8c6-41876478f966.png)

Finally, click the Save button to create the ```quan_le``` database. You will see the ```quan_le``` listed on the database list:

![image](https://user-images.githubusercontent.com/35042430/167922435-50ee40c0-a05e-4251-bbb5-dbc15e317781.png)

__Step 3)__ DB is created and shown in the Object tree.

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC8.png)

__Step 4)__ The right pane gives you the SQL used to create the Database.

![image](https://www.guru99.com/images/1/092818_0513_PostgreSQLC9.png)

#### Complete syntax to create a database

Here is complete Syntax to create a DB in PostgreSQL

```{Shell}
CREATE DATABASE db_name
OWNER =  role_name
TEMPLATE = template			
ENCODING = encoding			
LC_COLLATE = collate			
LC_CTYPE = ctype
TABLESPACE = tablespace_name
CONNECTION LIMIT = max_concurrent_connection
```

|Option	                  |Description  |
|--                       |--           |
|db_name                  |	Use this option to specify the name of the new database that you want to create. Although, you need to make sure that the database must be unique because If you attempt to create a new database with the same name as an existing database, PostgreSQL will display an error.|
|role_name                |	Use this parameter to define the the role name for the user who will own the new database. Default is postgres|
|Template                 |	You can specify database template name from which you want to creates the new database.|
|Encoding                 |	This parameter allows specifying character set encoding for the new database. Default is UTF8|
|Collate                  |	The collation parameter specifies the sort order of strings which affect the result of the ORDER BY clause while using a SELECT statement.|
|Ctype                    |	It specifies the character classification for the new database. It affects the categorization, e.g., digit, lower and upper.|
|tablespace_name          |	Using this option you can specify the tablespace name for the new database. The default is the template database’s tablespace.|
|max_concurrent_connection|	Use this option to specify the maximum concurrent connections to the new database. The default is -1, i.e., unlimited.|

Common Errors while using the ```createdb``` command

|Error	                    |Description  |
|--                         |--           |
|createdb command not found.|	This kind of error may occur when PostgreSQL is not installed correctly. At that time, you need need to run createdb command from your PostgreSQL installation path.|
|No such file in the server is running locally and accepting connections on Unix domain socket.|	This error occurs when PostgreSQL Server is not started properly, or it was not started where the createdb command wants it to start.|
|FATAL role “usr name” does not exist|	This error may occur if the PostgreSQL user account is created which are different from system user accounts.|
|Permission denied to create a database|	If the PostgreSQL account is created does not have permission to create a database In this case, you need to grant permission to the associated users to access create command.|
