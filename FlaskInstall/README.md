# FlaskInstall
Flask is a clean and simple web routing framework for Python and allows you to build web applications quickly (http://flask.pocoo.org/). This script allows you to deploy Flask on a fresh Ubuntu 14.04 installation. Tested - working with DigitalOcean. Using this script lets you start building your Flask web app in under 3 minutes - perfect for hackathons / prototyping. Features: 

- Installs Apache2 with WSGI
- Installs/configures Flask
- Installs/configures MySQL server w. database
- Creates a template Flask application with SQLAlchemy access (ORM)

# Download:
```
$ # Downloads flaskinstall.sh
$ wget https://raw.githubusercontent.com/NickTikhonov/scripts/master/FlaskInstall/flaskinstall.sh
$ # Makes the script executable
$ chmod +x flaskinstall.sh
$ # Runs flaskinstall as root
$ sudo ./flaskinstall.sh
```
