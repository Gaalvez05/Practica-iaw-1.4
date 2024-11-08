# Practica-iaw-1.4
Repositorio para la práctica 1.4. de IAW

Antonio Jesús Gálvez Rodríguez 2º A.S.I.R

En esta práctica vamos a crear un certificado **SSL/TLS** autofirmado con la herramienta `openssl`. Una vez creado vamos a configurar el servidor web Apache para que utilice dicho certificado.

# 1 HTTPS. Creación y configuración de un certificado SSL/TLS autofirmado en Apache
## 1.1 Instalación del servidor web Apache
En primer lugar deberemos tener instado un servidor web Apache en nuestra máquina. Si todavía no lo hemos instalado, podemos hacerlo con los siguientes comandos:
```
sudo apt update
sudo apt install apache2 -y
```

## 1.2 Creación del certificado autofirmado
Para crear un certificado autofirmado vamos a utilizar la utilidad openssl.

Este es el comando que vamos a utilizar:
```
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"
```
Vamos a explicar cada uno de los parámetros que hemos utilizado.

* `req`: El subcomando req se utiliza para crear solicitudes de certificado en formato PKCS#10. También puede utilizarse para crear certificados autofirmados, que será el uso que le daremos en esta práctica.

* `-x509`: Indica que queremos crear un certificado autofirmado en lugar de una solicitud de certificado, que se enviaría a una autoridad de certificación.

* `-nodes`: Indica que la clave privada del certificado no estará protegida por contraseña y estará sin encriptar. Esto permite a las aplicaciones usar el certificado sin tener que introducir una contraseña cada vez que se utilice.

* `-days 365`: Este parámetro indica la validez del certificado. En este caso hemos configurado una validez de 365 días.

* `-newkey rsa:2048`: Este parámetro indica que queremos generar una nueva clave privada RSA de 2048 bits junto con el certificado. La longitud de clave de 2048 bits es un estándar razonable para la seguridad en la actualidad.

* `-keyout /etc/ssl/private/apache-selfsigned.key`: Indica la ubicación y el nombre del archivo donde se guardará la clave privada generada. En este caso, hemos seleccionado que se guarde en la ruta /etc/ssl/private/apache-selfsigned.key.

* `-out /etc/ssl/certs/apache-selfsigned.crt`: Indica la ubicación y el nombre del archivo donde se guardará el certificado. En este caso, hemos seleccionado que se guarde en la ruta /etc/ssl/certs/apache-selfsigned.crt.

Al ejecutar el comando tendremos que introducir una serie de datos por teclado que se añadirán al certificado. Los datos que tenemos que introducir son los siguientes:
```
OPENSSL_COUNTRY="ES"
OPENSSL_PROVINCE="Almeria"
OPENSSL_LOCALITY="Almeria"
OPENSSL_ORGANIZATION="IES Celia"
OPENSSL_ORGUNIT="Departamento de Informatica"
OPENSSL_COMMON_NAME="practicahttps-ajgr.zapto.org"
OPENSSL_EMAIL="admin@iescelia.org"
```

Estos datos irán en el archivo `.env` de la carpeta `scripts`.
![](/img/Screenshot_20241108_124754.png)

# 1.3 Configuración de un VirtualHost con SSL/TSL en el servidor web Apache
## Paso 1: Editamos el archivo de configuración del virtual host donde queremos habilitar el tráfico HTTPS.

En nuestro caso, utilizaremos el archivo de configuración que tiene Apache por defecto para SSL/TLS, que está en la ruta: /etc/apache2/sites-available/default-ssl.conf.
El contenido del archivo será el siguiente:
```
<VirtualHost *:443>
    #ServerName practica-https.local
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
```

![](/img/Screenshot_20241108_121110.png)

Las directivas que hemos configurado son:

* `<VirtualHost *:443>`: Indica que este virtual host escuchará en el puerto 443 (HTTPS).

* `ServerName`: Indica el nombre de dominio y se utiliza para indicar al servidor web Apache qué peticiones debe servir para este virtual host. En nuestro ejemplo estamos utilizando el dominio practica-https.local.

* `DocumentRoot`: Es la ruta donde se encuentra el directorio raíz del host virtual.

* `SSLEngine on`: Configuramos que este virtual host utilizará SSL/TLS.

* `SSLCertificateFile`: Indica la ruta donde se encuentra el certificado autofirmado.

* `SSLCertificateKeyFile`: Indica la ruta donde se encuentra la clave privada del certificado autofirmado.

## Paso 2: Habilitamos el virtual host que acabamos de configurar.
```
sudo a2ensite default-ssl.conf
```
Hay que tener en cuenta que estamos utilizando el nombre de archivo default-ssl.conf porque estamos utilizando el archivo que tiene Apache por defecto para configurar un virtual host con SSL/TLS, pero en su caso puede ser otro.

## Paso 3: Habilitamos el módulo SSL en Apache.
```
sudo a2enmod ssl
```

## Paso 4: Configuramos el virtual host de HTTP para que redirija todo el tráfico a HTTPS.

En nuestro caso, el virtual host que maneja las peticiones HTTP está en el archivo de configuración que utiliza Apache por defecto para el puerto 80: /etc/apache2/sites-available/000-default.conf.

El contenido del archivo será el siguiente:
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

![](/img/Screenshot_20241108_121440.png)

Las directivas que hemos configurado son:

* `RewriteEngine On`: Habilita el motor de reescritura de URLs y nos permite usar reglas de reescritura.

* `RewriteCond %{HTTPS} off`: Esta directiva es una condición que comprueba si la petición recibida utiliza HTTPS o no. Si se cumple esta condición, entonces se ejecuta la siguiente línea.

* `RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]`: Las reglas de reescritura tienen la siguiente sintaxis RewriteRule Pattern Substitution   [flags].

    * Pattern: Es el patrón que se debe cumplir en la URL solicitada para que la regla de reescritura se aplique. En este caso, ^ coincide con el principio de la URL, por lo que se aplicará a todas las solicitudes.

    * Substitution: Es la URL a la que se redirige la solicitud. En este caso, se utiliza el valor https://%{HTTP_HOST}%{REQUEST_URI} y por lo tanto se redirige la solicitud a HTTPS manteniendo el mismo nombre de dominio y URI.

    * flags: Son los flags que se pueden utilizar para modificar el comportamiento de la regla de reescritura. En este caso, el flag [L,R=301] indica que es una redirección permanente (Código de estado: 301).

Las directivas utilizan las siguientes variables del servidor que se obtienen de la cabecera de la petición HTTP:

* `%{HTTPS}`: Contiene el texto on si la conexión utiliza SSL/TLS o off en caso contrario.

* `%{HTTP_HOST}`: Contiene el nombre de dominio que se ha utilizado en la petición del cliente para acceder al sitio web.

* `%{REQUEST_URI}`: Contiene la URI que ha utilizado el cliente para acceder al sitio web. Por ejemplo, /index.html. Si la petición incluye parámetros éstos estarán almacenados en la variable %{QUERY_STRING}.

## Paso 5
Para que el servidor web Apache pueda hacer la redirección de HTTP a HTTPS es necesario habilitar el módulo rewrite en Apache.
```
sudo a2enmod rewrite
```

## Paso 6: Reiniciamos el servicio de Apache
```
sudo systemctl restart apache2
```

Lo siguiente será comprobar que el puerto 443 está abierto en las reglas del firewall para permitir el tráfico HTTPS.

Al final de la práctica los archivos quedarían así:
```
.
├── README.md
├── conf
│   ├── 000-default.conf
│   └── default-ssl.conf
└── scripts
    ├── .env
    ├── install_lamp.sh
    └── setup_selfsigned_certificate.sh
```

![](/img/image.png)
![](/img/image2.png)
![](/img/image3.png)
