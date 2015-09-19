#!/bin/bash

# FlaskInstall by Nick Tikhonov
# installs Apache 2 with Flask on a fresh Ubuntu server

echo "------ FlaskInstall by Nick Tikhonov ------"
echo "NOTE: Please make sure you are running this on Ubuntu 13+"
echo "This script will install + configure:"
echo " -- Apache 2"
echo " -- Apache WSGI"
echo " -- MySQL (will configure app database)"
echo " -- Flask (will configure WSGI and create template project w. database ORM access)"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 1>&2
   exit 1
fi

echo "Please type anything to begin installation!"
read continueinstallation

echo "------------------------"
echo "Please enter a MySQL root password (this will be printed at the end):"
read mysql_password

echo "------------------------"
echo "Application Name (e.g. 'FlaskApp' or 'WebsiteApp' or 'HelloWorldApp'): "
read appname

echo "------------------------"
echo "Domain name or server IP address (e.g. mywebsite.net): "
read hostaddress

echo "------------------------"
echo "Admin email address (e.g. admin@mywebsite.net): "
read adminemail

echo "------------------------"
echo "Please enter a secret key (a long & secure string of characters): "
read secretkey

# Start by installing Apache 
sudo apt-get -y update
sudo apt-get -y install apache2
sudo apt-get -y install libapache2-mod-wsgi python-dev
sudo apt-get -y install libmysqlclient-dev
sudo a2enmod wsgi 

# Install MySQL Server

echo "mysql-server mysql-server/root_password password $mysql_password" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $mysql_password" | debconf-set-selections
sudo apt-get -y install mysql-server

# Create the template flask app
cd /var/www 

#make MySQL DB for the app
mysql -u root -p$mysql_password -e "create database $appname"

sudo mkdir $appname
cd $appname
sudo mkdir $appname 
cd $appname
sudo mkdir static templates

cat <<EOF > templates/index.html
<html>
<head>
	<title>$appname</title>
</head>
<body>
	<h1>Hello World!</h1></br>
	<p>FlaskInstall completed correctly!</p>
</body>
</html>
EOF

cat <<EOF > __init__.py
from flask import Flask, render_template
from flask.ext.sqlalchemy import SQLAlchemy
import flask.ext.restless

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:$mysql_password@localhost/$appname'
db = SQLAlchemy(app)

# ------------------------------------------
# Database ORM Section - with Flask SQLAlchemy
# ------------------------------------------

# Example ORM model - please modify to your requirements
# SQL Alchemy quick reference: pythonhosted.org/Flask-SQLAlchemy/quickstart.html
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True)
    email = db.Column(db.String(120), unique=True)

    def __init__(self, username, email):
        self.username = username
        self.email = email

    def __repr__(self):
        return '<User %r>' % self.username

# ------------------------------------------
# Database API Section - with Flask Restless
# ------------------------------------------

manager = flask.ext.restless.APIManager(app, flask_sqlalchemy_db=db)
manager.create_api(User, methods=['GET', 'POST', 'DELETE'])


# ------------------------------------------
# Routing Section
# ------------------------------------------

# Sets up the database - visit this page after configuring 
# SQLAlchemy models above 
@app.route("/mysql_db_setup")
def db_setup():
	try:
		# Database setup logic
		db.create_all()
		return "Database setup was successfull, please disable db_setup() in your application"
	except Exception, e:
		return str(e)

# Root page - please change as required
@app.route("/")
def index():
	try:
		# Index logic goes here 
		return render_template("index.html")
	except Exception, e:
		return str(e)

if __name__ == "__main__":
	app.run()
EOF

# Install Flask, Flask-MySQL
sudo apt-get -y install python-pip
sudo pip install Flask
sudo pip install flask-mysql
sudo pip install Flask-SQLAlchemy
sudo pip install Flask-Restless

cat <<EOF > /etc/apache2/sites-available/$appname.conf
<VirtualHost *:80>
		ServerName $hostaddress
		ServerAdmin $adminemail
		WSGIScriptAlias / /var/www/$appname/$appname.wsgi
		<Directory /var/www/$appname/$appname/>
			Order allow,deny
			Allow from all
		</Directory>
		Alias /static /var/www/$appname/$appname/static
		<Directory /var/www/$appname/$appname/static/>
			Order allow,deny
			Allow from all
		</Directory>
		ErrorLog ${APACHE_LOG_DIR}/error.log
		LogLevel warn
		CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo a2dissite 000-default
sudo a2ensite $appname

cat <<EOF > /var/www/$appname/$appname.wsgi
#!/usr/bin/python
import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0,"/var/www/$appname/")

from $appname import app as application
application.secret_key = '$secretkey'
EOF

sudo service apache2 restart

echo "Done! Please visit $hostaddress to check that everything works"
echo "|---------------------------------"
echo "| App name       : $appname       "
echo "| init file      : /var/www/$appname/$appname/__init__.py"
echo "| Address        : $hostaddress   "
echo "| MySQL password : $mysql_password"
echo "| Secret Key     : $secretkey     "
echo "|---------------------------------"
