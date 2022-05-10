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
