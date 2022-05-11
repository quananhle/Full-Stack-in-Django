## Connect To a PostgreSQL Database Server

__Summary:__ in this tutorial, you will learn how to __connect to the PostgreSQL Database Server__ via an interactive terminal program called ```psql``` and via the ```pgAdmin``` application.

When you [installed the PostgreSQL database server](https://github.com/Quananhle/Full-Stack-in-Django/tree/main/Database/Guide/Install-PostgreSQL-on-Windows), the PostgreSQL installer also installed some useful tools for working with the PostgreSQL database server. In this tutorial, you will learn how to connect to the PostgreSQL database server via the following tools:

- psql – a terminal-based front-end to PostgreSQL database server.
- pgAdmin – a web-based front-end to PostgreSQL database server.

### 1) Connect to PostgreSQL database server using psql

psql is an interactive terminal program provided by PostgreSQL. It allows you to interact with the PostgreSQL database server such as executing SQL statements and managing database objects.

The following steps show you how to connect to the PostgreSQL database server via the psql program:

First, launch the ```psql``` program and connect to the PostgreSQL Database Server using the ```postgres``` user:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Install-PostgreSQL-psql.png)

Second, enter all the information such as Server, Database, Port, Username, and Password. If you press Enter, the program will use the default value specified in the square bracket ```[]``` and move the cursor to the new line. For example, ```localhost``` is the default database server. In the step for entering the password for user postgres, you need to enter the password the user postgres that you chose during the [PostgreSQL installation](https://github.com/Quananhle/Full-Stack-in-Django/tree/main/Database/Guide/Install-PostgreSQL-on-Windows).

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Connect-to-PostgreSQL-via-psql.png)

Third, interact with the PostgreSQL Database Server by issuing an SQL statement. The following statement returns the current version of PostgreSQL:

```{SQL}
SELECT version();
```

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Install-PostgreSQL-psql-verification.png)

### 2) Connect to PostgreSQL database server using pgAdmin

The second way to connect to a database is by using a pgAdmin application. The pgAdmin application allows you to interact with the PostgreSQL database server via an intuitive user interface.

The following illustrates how to connect to a database using pgAdmin GUI application:

First, launch the pgAdmin application.

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Connect-to-PostgreSQL-via-pgAdmin.png)

The pgAdmin application will launch on the web browser as shown in the following picture:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/pgAdmin-4.png)

Second, right-click the Servers node and select Create > Server… menu to create a server

![image](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/pgAdmin-create-a-server.png)

Third, enter the server name e.g., PostgreSQL and click the Connection tab:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/pgAdmin-enter-the-server-name.png)

Fourth, enter the host and password for the postgres user and click the Save button:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/pgAdmin-enter-host-and-user-info.png)

Fifth, click on the Servers node to expand the server. By default, PostgreSQL has a database named postgres as shown below:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/pgAdmin-connected-to-PostgreSQL-Database-Server.png)

Sixth, open the query tool by choosing the menu item Tool > Query Tool or click the lightning icon.

![image](https://www.postgresqltutorial.com/wp-content/uploads/2019/05/pgAdmin-query-tool.png)

Seventh, enter the query in the Query Editor, click the Execute button, you will see the result of the query displaying in the Data Output tab:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Connect-to-PostgreSQL-via-pgAdmin-Execute-a-query-1.png)

### Connect to PostgreSQL database from DBeaver
### Connect to PostgreSQL database from Python

__Summary:__ in this tutorial, you will learn how to connect to the PostgreSQL database server in the Python program using the psycopg database adapter.

Install the ```psycopg2``` module
First, visit the [psycopg2 package here](https://pypi.org/project/psycopg2/).

Second, use the following command line from the terminal:

```{Shell}
pip install psycopg2
```

If you have downloaded the source package into your computer, you can use the setup.py as follows:

```{Shell}
python setup.py build
sudo python setup.py install
```

#### Create a new database

First, log in to the PostgreSQL database server using any client tool such as pgAdmin or psql.

Second, use the following statement to [create a new database](https://github.com/Quananhle/Full-Stack-in-Django/tree/main/Database/Guide/Create-New-Database) named ```suppliers``` in the PostgreSQL database server.

```{SQL}
CREATE DATABASE suppliers;
```

#### Connect to the PostgreSQL database using the psycopg2

To connect to the ```suppliers``` database, you use the ```connect()``` function of the ```psycopg2``` module.

The ```connect()``` function creates a new database session and returns a new instance of the ```connection``` class. By using the ```connection``` object, you can create a new ```cursor``` to execute any SQL statements.

To call the ```connect()``` function, you specify the PostgreSQL database parameters as a connection string and pass it to the function like this:

```{Shell}
conn = psycopg2.connect("dbname=suppliers user=postgres password=postgres")
```

Or you can use a list of keyword arguments:

```{Python}
conn = psycopg2.connect(
    host="localhost",
    database="suppliers",
    user="postgres",
    password="Abcd1234")
```

The following is the list of the connection parameters:

- ```database```: the name of the database that you want to connect.
user: the username used to authenticate.
password: password used to authenticate.
host: database server address e.g., localhost or an IP address.
port: the port number that defaults to 5432 if it is not provided.
To make it more convenient, you can use a configuration file to store all connection parameters.
