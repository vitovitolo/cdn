#ª/bin/bash

openssl genrsa -out cdn.key 2048
openssl req -new -key cdn.key -out cdn.csr
openssl x509 -req -days 365 -in  cdn.csr -signkey cdn.key -out cdn.crt
cat cdn.crt cdn.key >> cdn.pem
