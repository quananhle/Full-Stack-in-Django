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
