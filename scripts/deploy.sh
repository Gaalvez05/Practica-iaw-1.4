#!/bin/bash

# Importamos el archivo de variables
source .env

# Para mostrar los comandos que se van ejecutando
set -ex

#Eliminamos clonados precios de la aplicacion
rm -rf /tmp/iaw-practica-lamp

# Clonamos el repositorio de la aplicacion en /tmp
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp

# Movemos el codigo fuente de la aplicacion a /var/www/html
mv /tmp/iaw-practica-lamp/src/* /var/www/html

# Configuramos el archivo config.php
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/config.php

# Creamos una base de datos de ejemplo
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
mysql -u root <<< "CREATE DATABASE $DB_NAME"

# Creamos u usuario para la base de datos de ejemplo
mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"

#Configuramos el script de SQL con el nombre de la base de datos
sed -i "s/lamp_db/$DB_NAME/" /tmp/iaw-practica-lamp/db/database.sql

#Creamos las tablas de la base de datos
mysql -u root < /tmp/iaw-practica-lamp/db/database.sql