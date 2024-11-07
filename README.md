# Practica-iaw-1.4
Repositorio para la práctica 1.4. de IAW

Antonio Jesús Gálvez Rodríguez 2º A.S.I.R

En esta práctica vamos a crear un certificado **SSL/TLS** autofirmado con la herramienta `openssl`. Una vez creado vamos a configurar el servidor web Apache para que utilice dicho certificado.

# 1 Archivo `install_lamp.sh`
Lo primero será instalar la pila LAMP, dentro de la carpeta `scripts` donde crearemos un archivo llamado `install_lamp.sh` donde lo instalaremos.

En la cabecera de nuestro archivo creado pondremos lo siguiente:
```
#!/bin/bash
```
Esto indica que el script debe ejecutarse con el intérprete de Bash e irá siempre en la cabecera del archivo.
```
set -ex
```
Este comando hace que el script muestre cada comando antes de ejecutarlo `(-x)` y salga si algún comando falla `(-e)`.

## 1.1 Actualización del Sistema
### 1.1.1 Actualizar los repositorios
 ```
apt update
```
Actualiza la lista de paquetes disponibles en los repositorios configurados.

### 1.1.2 Actualizar los paquetes
```
apt upgrade -y
```
Actualiza todos los paquetes instalados a sus versiones más recientes. El `-y` automáticamente acepta todas las confirmaciones.

## 1.2 Instalación de Apache
### 1.2.1 Instalar el servidor web Apache
```
apt install apache2 -y
```
Instala el servidor web Apache. El -y hace lo mismo que se ha explicado anteriormente

### 1.2.1.1 Habilitar el módulo rewrite de Apache
```
a2enmod rewrite
```
Habilita el módulo rewrite de Apache, que es útil para la reescritura de URL's.

### 1.2.2 Creación del archivo de configuración de Apache
Crearemos una carpeta llamada `conf` en la que crearemos un primer archivo `000-default.conf` donde incluiremos el siguiente contenido:
```
<VirtualHost *:80>
    #ServerName practica-https.local
    DocumentRoot /var/www/html

    # Redirige al puerto 443 (HTTPS)
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>
```
Esto nos permitirá que cualquier petición que entre por el **puerto 80** `http` sea automáticamente redirigida al **puerto 443** donde tenemos el protocolo `https`.

### 1.2.2.2 Copiar archivo de configuración de Apache
```
cp ../conf/000-default.conf /etc/apache2/sites-available
```
Con esto vamos a conseguir copiar el archivo de configuración personalizado de Apache al directorio donde Apache busca sus configuraciones de sitios disponibles.

## 1.3. Instalación de PHP
### 1.3.1 Instalar PHP y los módulos de PHP para Apache y MySQL
```
apt install php libapache2-mod-php php-mysql -y
```
Instala PHP y los módulos necesarios para que Apache pueda procesar scripts PHP y para que PHP pueda interactuar con MySQL.

## 1.3.2 Reiniciar Apache
### 1.3.2.1 Reiniciar el servicio de Apache
```
systemctl restart apache2
```
Reinicia el servicio de Apache para aplicar los cambios de configuración y cargar los nuevos módulos instalados.

## 1.4. Instalación de MySQL
### 1.4.1 Instalar MySQL Server
```
apt install mysql-server -y
```
Instala el servidor de base de datos MySQL.

### 1.4.1.1 Configuración Adicional
### 1.4.1.2 Copiar el script de prueba de PHP a `/var/www/html`
```
cp ../php/index.php /var/www/html
```

Copia un script de prueba PHP a la raíz del servidor web, permitiendo verificar que PHP está funcionando correctamente.

### 1.4.1.3 Modificar el propietario y el grupo del archivo `index.php`
```
chown -R www-data:www-data /var/www/html
```
Cambia el propietario y el grupo del archivo index.php y de todos los archivos en el directorio /var/www/html a www-data, que es el usuario y grupo predeterminados de Apache.

# 2 Archivo `install_tools.conf`
## 2.1 Configuración inicial del archivo
En la carpeta `scripts`crearemos otro archivo creado `install_tools.conf` con el siguiente contenido:
```  
#!/bin/bash

set -ex

apt update

apt upgrade -y
```
Los primeros comandos que pondremos serán idénticos a los del archivo anterior y que, como ya explicamos, serán fundamentales para los comandos que irán posteriormente.

## 2.2 Configuración de phpMyAdmin
### 2.2.1 Configurar las respuestas para la instalación de phpMyAdmin
```
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
```
Estos comandos configuran las respuestas para el proceso interactivo de instalación de phpMyAdmin, esto permitirá que toda la instalación sea automática y que no necesitemos de una persona respondiendo.

## 2.3 Instalar phpMyAdmin
```
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
```
Instala phpMyAdmin junto con algunos módulos PHP adicionales necesarios.

![](/img/Captura%20de%20pantalla%202024-11-07%20204107.png)

### 2.3.1 Archivo `index.php`
Crearemos una carpeta llamada `php` donde incluiremos el archivo `index.php` con el siguiente contenido.
```
<?php

phpinfo();

?>
```

## 2.4 Instalación de Adminer
### Paso 1: Crear un directorio para Adminer
```
mkdir -p /var/www/html/adminer
```
Crea el directorio donde se aloja Adminer.

### Paso 2: Descargar Adminer
```
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer
```
Descarga el script de Adminer a la carpeta creada.

### Paso 3: Renombrar el script de Adminer
```
mv /var/www/html/adminer/adminer-4.8.1-mysql.php /var/www/html/adminer/index.php
```
Renombra el script descargado a index.php para facilitar el acceso al archivo.

### Paso 4: Modificar el propietario y grupo del archivo
```
chown -R www-data:www-data /var/www/html/adminer
```
Cambia el propietario y grupo del directorio de Adminer a www-data, el usuario y grupo predeterminados de Apache.

![](/img/Captura%20de%20pantalla%202024-11-07%20202302.png)

##  2.5 Instalación de GoAccess
### 2.5.1 Instalar GoAccess
```
apt install goaccess -y
```
Instala GoAccess, una herramienta de análisis de registros de acceso de Apache.

### 2.5.1.1 Crear un directorio para los informes estadísticos
```
mkdir -p /var/www/html/stats
```
Crea un directorio donde se almacenarán los informes generados por GoAccess.

### 2.5.2 Ejecutar GoAccess en segundo plano
```
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize
```
Ejecuta GoAccess en segundo plano para generar informes en tiempo real basados en los registros de acceso de Apache.

![](/img/Captura%20de%20pantalla%202024-11-07%20202500.png)

# 3 Archivo `deploy.sh`
## 3.1 Configuración inicial del archivo
En la carpeta `scripts`crearemos otro archivo creado `deploy.sh` con el siguiente contenido:
```  
#!/bin/bash

set -ex

source env.
```
Los primeros comandos que utilizaremos serán para ver los comandos que se van ejecutando `-e` y para que pare en caso de que se produzca un error `-x`.

## 3.2 Eliminamos clonados previos de la aplicación
```
rm -rf /tmp/iaw-practica-lamp
```
Este comando elimina la carpeta temporal /tmp/iaw-practica-lamp si existe, incluyendo cualquier contenido previo. Esto asegura que no queden archivos de ejecuciones anteriores.

## 3.4 Clonamos el repositorio de la aplicación en /tmp
```
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/iaw-practica-lamp
```
Aquí se clona el repositorio de la aplicación desde GitHub en la carpeta `/tmp/iaw-practica-lamp`. Esta carpeta temporal servirá como espacio para la copia del repositorio antes de moverlo a su ubicación final.

## 3.5 Movemos el código fuente de la aplicación a /var/www/html
```
mv /tmp/iaw-practica-lamp/src/* /var/www/html
```
Este comando mueve todos los archivos fuente de la carpeta temporal `/tmp/iaw-practica-lamp/src/` a `/var/www/html`, que es donde el servidor web (Apache) sirve la aplicación.

## 3.6 Configuramos el archivo config.php
```
sed -i "s/database_name_here/$DB_NAME/" /var/www/html/config.php
sed -i "s/username_here/$DB_USER/" /var/www/html/config.php
sed -i "s/password_here/$DB_PASSWORD/" /var/www/html/config.php
```
Estos comandos usan `sed` para reemplazar las variables de configuración en el archivo `config.php` de la aplicación con las correspondientes variables de entorno ($DB_NAME, $DB_USER, $DB_PASSWORD). Así, el archivo config.php queda configurado correctamente para la conexión a la base de datos.

![](/img/config.php.png)

## 3.7 Creación de una Base de Datos de Ejemplo
### 3.7.1 Eliminar la base de datos si existe
```
mysql -u root <<< "DROP DATABASE IF EXISTS $DB_NAME"
```
Elimina la base de datos con el nombre $DB_NAME si ya existe.

### 3.7.2 Crear una nueva base de datos
```
mysql -u root <<< "CREATE DATABASE $DB_NAME"
```
Crea una nueva base de datos con el nombre $DB_NAME.

### 3.7.3 Crear un usuario para la base de datos de ejemplo
```
mysql -u root <<< "DROP USER IF EXISTS '$DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%'"
```
Crea un nuevo usuario de base de datos y le otorga todos los privilegios sobre la nueva base de datos.

![](/img/Captura%20de%20pantalla%202024-11-07%20204500.png)

![](/img/Captura%20de%20pantalla%202024-11-07%20204625.png)

## 3.8 Creación del archivo `.env`
Este archivo irá sobre la carpeta `script` y nos ayudará a declarar todas las variables que hemos visto anteriormente `(con un "$" delante)` y así no tengamos que declararlas en este archivo, ocupando así, más espacio.

### 3.8.1 Contenido del archivo `.env`
Una vez creado nos meteremos y pondremos todas las variables que han ido apareciendo con su declaración, de esta manera:
```
PHPMYADMIN_APP_PASSWORD=password
DB_USER=usuario
DB_PASSWORD=password
DB_NAME=basededatos
```
Así sabrá el script cuál es el dato de cada variable de entorno sin tener que ponerla nosotros.

## 3.9 Configuramos el script de SQL con el nombre de la base de datos
```
sed -i "s/lamp_db/$DB_NAME/" /tmp/iaw-practica-lamp/db/database.sql
```
Aquí, se modifica el archivo database.sql para reemplazar el nombre de la base de datos predeterminado (lamp_db) por el valor de $DB_NAME.

## 3.10 Creamos las tablas de la base de datos
```
mysql -u root < /tmp/iaw-practica-lamp/db/database.sql
```
Este último comando ejecuta el script SQL database.sql, que crea las tablas necesarias en la base de datos. Se conecta a MySQL como root y le indica que ejecute el contenido del archivo SQL.