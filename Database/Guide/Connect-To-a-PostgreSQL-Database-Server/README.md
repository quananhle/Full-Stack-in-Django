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
- ```user```: the username used to authenticate.
- ```password```: password used to authenticate.
- ```host```: database server address e.g., localhost or an IP address.
- ```port```: the port number that defaults to 5432 if it is not provided.

To make it more convenient, you can use a configuration file to store all connection parameters.

The following shows the contents of the ```database.ini``` file:

```{Python}
[postgresql]
host=localhost
database=suppliers
user=postgres
password=SecurePas$1
```

By using the ```database.ini```, you can change the PostgreSQL connection parameters when you move the code to the production environment without modifying the code.

Notice that if you git, you need to add the ```database.ini``` to the ```.gitignore``` file to not committing the sensitive information to the public repo like github. The ```.gitignore``` file will be like this:

```{Shell}
database.ini
```

The following ```config()``` function read the ```database.ini``` file and returns connection parameters. The ```config()``` function is placed in the ```config.py``` file:

```{Python}
#!/usr/bin/python
from configparser import ConfigParser


def config(filename='database.ini', section='postgresql'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return db
```

The following ```connect()``` function connects to the ```suppliers``` database and prints out the PostgreSQL database version.

```{Python}
#!/usr/bin/python
import psycopg2
from config import config

def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config()

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
		
        # create a cursor
        cur = conn.cursor()
        
	# execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
       
	# close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')


if __name__ == '__main__':
    connect()
```

How it works.

- First, read database connection parameters from the ```database.ini``` file.
- Next, create a new database connection by calling the ```connect()``` function.
- Then, create a new ```cursor``` and execute an SQL statement to get the PostgreSQL database version.
- After that, read the result set by calling the  ```fetchone()``` method of the cursor object.
- Finally, close the communication with the database server by calling the ```close()``` method of the cursor and connection objects.

#### Execute the connect.py file

To execute the ```connect.py``` file, you use the following command:

```{Shell}
python connect.py
```

You will see the following output:

```{Shell}
Connecting to the PostgreSQL database...
PostgreSQL database version:
('PostgreSQL 12.3, compiled by Visual C++ build 1914, 64-bit',)
Database connection closed.
```

It means that you have successfully connected to the PostgreSQL database server.

#### Troubleshooting

The ```connect()``` function raises the DatabaseError exception if an error occurred. To see how it works, you can change the connection parameters in the ```database.ini``` file.

For example, if you change the host to ```localhosts```, the program will output the following message:

```{Shell}
Connecting to the PostgreSQL database...
could not translate host name "localhosts" to address: Unknown host
```

The following displays error message when you change the database to a database that does not exist e.g., ```supplier```:

```{Shell}
Connecting to the PostgreSQL database...
FATAL: database "supplier" does not exist
```

If you change the user to ```postgress```, it will not be authenticated successfully as follows:

```{Shell}
Connecting to the PostgreSQL database...
FATAL: password authentication failed for user "postgress"
```

In this tutorial, you have learned how to connect to the PostgreSQL database server from Python programs.
