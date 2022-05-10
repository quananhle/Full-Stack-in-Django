# Install PostgreSQL on Windows

### 1) Download PostgreSQL Installer for Windows

First, you need to go to the download page of PostgreSQL installers on the EnterpriseDB.

Second, click the download link as shown below:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Download-PostgreSQL.png)

### 2) Install PostgreSQL on Window step by step

To install PostgreSQL on Windows, you need to have administrator privileges.

__Step 1.__ Double click on the installer file, an installation wizard will appear and guide you through multiple steps where you can choose different options that you would like to have in PostgreSQL.

__Step 2.__ Click the __Next__ button

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Install-PostgreSQL-12-Windows-Step-1.png)

__Step 3.__ Specify installation folder, choose your own or keep the default folder suggested by PostgreSQL installer and click the Next button

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Install-PostgreSQL-12-Windows-Step-2.png)

__Step 4.__ Select software components to install:

- The PostgreSQL Server to install the PostgreSQL database server
- pgAdmin 4 to install the PostgreSQL database GUI management tool.
- Command Line Tools to install command-line tools such as psql, pg_restore, etc. These tools allow you to interact with the PostgreSQL database server using the command-line interface.
- Stack Builder provides a GUI that allows you to download and install drivers that work with PostgreSQL.

For the tutorial on this website, you don’t need to install Stack Builder so feel free to uncheck it and click the Next button to select the data directory:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Install-PostgreSQL-12-Windows-Step-3.png)

__Step 5.__ Select the database directory to store the data or accept the default folder. And click the Next button to go to the next step:

![image](https://www.postgresqltutorial.com/wp-content/uploads/2020/07/Install-PostgreSQL-12-Windows-Step-4.png)

__Step 6.__ Enter the password for the database superuser (postgres)

PostgreSQL runs as a service in the background under a service account named postgres. If you already created a service account with the name postgres, you need to provide the password of that account in the following window.

After entering the password, you need to retype it to confirm and click the Next button:

![image](https://user-images.githubusercontent.com/35042430/167675587-187c9725-2c3e-49c4-860b-b537e153dde2.png)


