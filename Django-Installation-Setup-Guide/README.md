## Django

### Set up Django and virtual environment for VSCode

1. Install Python extension for Visual Studio Code here or press ```Ctrl + Shift + X``` in VSCode and type in Python. On installing, select ```Customize``` to ```Add Python to environment variables```

![image](https://user-images.githubusercontent.com/35042430/167447903-df7ec6f8-88dd-42af-89da-d98b3d37c6d8.png)

![image](https://user-images.githubusercontent.com/35042430/167448019-67530f54-d942-4159-9bbc-74c371210c57.png)

2. Open __Terminal__ and check Python version of the system using command ```py --version```
3. (Optional) In case of the error message
```Python was not found; run without arguments to install from the Microsoft Store, or disable this shortcut from Settings > Manage App Execution Aliases```, press __Windows__ to open __Manage app execution alias__ to turn off Python aliases

![image](https://user-images.githubusercontent.com/35042430/167448673-8171d445-3f10-4fd0-9b2c-dc94c999e712.png)

Press __Windows__ again to open __Environment Variables__ to add __Python PATH__ to __System variables__

```C:\Users\username\AppData\Local\Programs\Python\Python310\```

```C:\Users\username\AppData\Local\Programs\Python\Python310\Scripts\```

![image](https://user-images.githubusercontent.com/35042430/167449292-779abfef-8540-48e3-a01c-88188a8a3730.png)

4. Create a virtual environment using the following command, where ```.venv``` is the name of the environment folder:

```{Shell}
# Linux
sudo apt-get install python3-venv
# If needed
python3 -m venv .venv
# activate virtual environmentpy
source .venv/bin/activate

# macOS
python3 -m venv .venv
# activate virtual environment
source .venv/bin/activate

# Windows
py -3 -m venv .venv
# activate virtual environment
.venv\Scripts\activate
```

When you create a new virtual environment, a prompt will be displayed to allow you to select it for the workspace.

![image](https://user-images.githubusercontent.com/35042430/167449514-5704bed8-d9d4-4413-8f50-7b102ab5847e.png)

This will add the path to the Python interpreter from the new virtual environment to your workspace settings. That environment will then be used when installing packages and running code through the Python extension.

5. Open the project folder in VS Code by running ```code .```, or by running VS Code and using the __File > Open Folder__ command.
6. In VS Code, open the ```Command Palette``` (__View > Command Palette__ or __(Ctrl+Shift+P)__). Then select the ```Python: Select Interpreter``` command, and  select the virtual environment in your project folder that starts with ```./.venv``` or ```.\.venv```

![image](https://user-images.githubusercontent.com/35042430/167457807-7144204f-9ee3-4c93-bd89-3c3a4716e255.png)

7. Run ```Terminal: Create New Terminal``` (__Ctrl+Shift+`__) from the ```Command Palette```, which creates a terminal and automatically activates the virtual environment by running its activation script.

![image](https://user-images.githubusercontent.com/35042430/167457935-71eb6862-7cec-498a-bcb9-19e07daaeea3.png)

If virtual environment does not activate automatically, change direction to the Django project which has the direction ```.venv/Scripts```. Manually execute the following command ```.venv\Scripts\activate```

![image](https://user-images.githubusercontent.com/35042430/167458352-e21b83da-d185-4be6-9f02-dd14e1766b4e.png)

8. (Optional) In case of the error message

![image](https://user-images.githubusercontent.com/35042430/167458468-3fc1aaae-caec-425d-a6e8-2efbac4055fb.png)
& : File D:\Projects\cims\.venv\Scripts\Activate.ps1 cannot be loaded because running scripts is disabled on this system.

execute the below command and create new Terminal again

![image](https://user-images.githubusercontent.com/35042430/167458752-a9a76b18-6049-4f84-8f9e-721234b9855d.png)

```{Shell}
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

9. While in virtual environment, install or upgrade existing pip in the system using the following command

```python -m pip install --upgrade pip```

![image](https://user-images.githubusercontent.com/35042430/167459536-6a8ceda2-e36a-418c-970b-3449854f07db.png)

![image](https://user-images.githubusercontent.com/35042430/167459596-e43d295e-588b-449d-9b09-bb27a1fa3a1f.png)

10. Install Django in the virtual environment by runnipng the following command in the VS Code Terminal:z

```python -m pip install django```

![image](https://user-images.githubusercontent.com/35042430/167459701-85cb1152-61dd-431b-9ffe-d208d75b9872.png)

![image](https://user-images.githubusercontent.com/35042430/167459728-b5c6a372-4ff0-4633-a8a9-5ba1610026da.png)

11. Create the Django project in the VS Code Terminal by executing the following command:

```django-admin startproject web_project .```

12. Create an empty development database by running the following command:

```python manage.py migrate```

13. To verify the Django project, make sure your virtual environment is activated, then start Django's development server using the command ```python manage.py runserver```. The server runs on the default port 8000, and you see output like the following output in the terminal window:

![image](https://user-images.githubusercontent.com/35042430/167459889-9bdb3709-a36e-43f0-9117-4deafee98c86.png)

14. __Ctrl+click__ the ```http://127.0.0.1:8000/ URL``` in the terminal output window to open your default browser to that address. If Django is installed correctly and the project is valid, you see the default page shown below. The VS Code terminal output window also shows the server log.

![image](https://user-images.githubusercontent.com/35042430/167460027-c99a6290-26dd-45d8-9a12-c5aaad3ad99b.png)

### Start a project

```{Shell}
$ python -m django --version
```

![image](https://user-images.githubusercontent.com/35042430/167464601-191abec3-fa51-4211-9c4d-b3d6f76a53fd.png)

![image](https://user-images.githubusercontent.com/35042430/167464819-9bab1706-8c48-40fa-9ba5-2a811a55654e.png)

```startproject``` should have created:

```{Shell} 
$ django-admin startproject mysite 
```
```{Shell} 
$ cd mysite
```
```{Shell}
mysite/
    manage.py
    mysite/
        __init__.py
        settings.py
        urls.py
        asgi.py
        wsgi.py
```

```{Shell}
$ python manage.py migrate
$ python manage.py runserver
```

![image](https://user-images.githubusercontent.com/35042430/167465648-2a62f131-f42a-433d-82b9-4eaeb17038b7.png)

![image](https://user-images.githubusercontent.com/35042430/176514733-88939fd9-8bdd-4135-9f93-8de2d6c93007.png)

