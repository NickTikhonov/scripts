#!/bin/bash

# FlaskInstall by Nick Tikhonov
# installs Apache 2 with Flask on a fresh Ubuntu server

# Start by installing Apache 
sudo apt-get update
sudo apt-get install apache2
sudo apt-get install libapache2-mod-wsgi python-dev
sudo a2enmod wsgi 

# Create the template flask app
cd /var/www 

echo "Application Name (e.g. 'FlaskApp' or 'WebsiteApp'): "
read appname

sudo mkdir $appname
cd $appname
sudo mkdir $appname 
cd $appname
sudo mkdir static templates

cat <<EOF > __init__.py
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
	return "Hello World! FlaskInstall ran correctly!"
if __name__ == "__main__":
	app.run()
EOF

# Install Flask
sudo apt-get install python-pip
sudo pip install Flask

echo "Domain name or server IP address: "
read hostaddress

echo "Admin email address: "
read adminemail

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

sudo a2ensite $appname

echo "Please enter a secret key (punch the keyboard a few times): "
read secretkey

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
echo "App name : $appname"
echo "Address  : $hostaddress"