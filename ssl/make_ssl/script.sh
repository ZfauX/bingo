#!/usr/bin/env bash

# Generating a private key for the root certificate
openssl req -new -nodes -text -out root.csr -keyout root.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=*.home.me"
chmod og-rwx root.key

# Root certificate generation
openssl x509 -req -in root.csr -text -days 365 -extfile /etc/ssl/openssl.cnf -extensions v3_ca -signkey root.key -out root.crt

# Generating a private key for the database №1 certificate
openssl req -new -nodes -text -out server1.csr -keyout server1.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=db1.home.me"
    chmod og-rwx server1.key

# Database №1 certificate generation
openssl x509 -req -in server1.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out server1.crt -extfile myssldb1.cnf -extensions req_ext

# Generating a private key for the database №2 certificate
openssl req -new -nodes -text -out server2.csr -keyout server2.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=db2.home.me"
chmod og-rwx server2.key

# Database №2 certificate generation
openssl x509 -req -in server2.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out server2.crt -extfile myssldb2.cnf -extensions req_ext

# Private key generation for the client
openssl req -new -nodes -text -out postgresql.csr -keyout postgresql.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=postgres"
chmod og-rwx postgresql.key

# Certificate generation for the client
openssl x509 -req -in postgresql.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out postgresql.crt
