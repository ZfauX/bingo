#!/usr/bin/env bash

# Generating a private key for the root certificate
openssl req -new -nodes -text -out root.csr -keyout root.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=*.local"
chmod og-rwx root.key

# Root certificate generation
openssl x509 -req -in root.csr -text -days 365 -extfile /etc/ssl/openssl.cnf -extensions v3_ca -signkey root.key -out root.crt

# Generating a private key for the database №1 certificate
openssl req -new -nodes -text -out server1.csr -keyout server1.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=db-01.local"
    chmod og-rwx server1.key

# Database №1 certificate generation
openssl x509 -req -in server1.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out server1.crt -extfile myssldb1.cnf -extensions req_ext

# Generating a private key for the database №2 certificate
openssl req -new -nodes -text -out server2.csr -keyout server2.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=db-02.local"
chmod og-rwx server2.key

# Database №2 certificate generation
openssl x509 -req -in server2.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out server2.crt -extfile myssldb2.cnf -extensions req_ext

# Private key generation for the client №1
openssl req -new -nodes -text -out postgresql1.csr -keyout postgresql1.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=postgres"
chmod og-rwx postgresql1.key

# Certificate generation for the client №1
openssl x509 -req -in postgresql1.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out postgresql1.crt

# Private key generation for the client №2
openssl req -new -nodes -text -out postgresql2.csr -keyout postgresql2.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=postgres"
chmod og-rwx postgresql2.key

# Certificate generation for the client №2
openssl x509 -req -in postgresql2.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out postgresql2.crt

# Private key generation for the replication client №1
openssl req -new -nodes -text -out postgresql3.csr -keyout postgresql3.key -subj "/C=RU/ST=Moskovskaya oblast'/L=Volokolamsk/O=Home/OU=IT/CN=postgres"
chmod og-rwx postgresql3.key

# Certificate generation for the replication client №1
openssl x509 -req -in postgresql3.csr -text -days 365 -CA root.crt -CAkey root.key -CAcreateserial -out postgresql3.crt
