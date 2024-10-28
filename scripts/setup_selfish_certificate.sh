#!/bin/bash

#Mostrar los comandos que se van ejecutando 
set -ex

# Importamos las variables de entorno
source .env

# Creamos el certificado autofirmado
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

#Copiamos el archivo de virtualhost del puerto 443
cp ../conf/default-ssl.conf /etc/apache2/sites-available

# Habilitamos el virtual host que acabamos de configurar.
sudo a2ensite default-ssl.conf

# Habilitamos el módulo SSL en Apache.
sudo a2enmod ssl

# Copiamos el archivo de configuracion del VirtualHost del puerto 80
cp ../conf/000-default.conf /etc/apache2/sites-available

#Habilitamos el archivo de configuracion
a2ensite 000-default.conf

#Habilitamos el modulo de rewrite
a2enmod rewrite

#Reiniciamos el servicio de Apche
systemctl restart apache2