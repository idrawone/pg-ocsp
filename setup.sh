#!/bin/bash

echo "cat setup.sh, and run manually for now"
exit

# 1) setup ocsp env
## git clone git@github.com:idrawone/ocsp.git
## cd ocsp
## ./myocsp.sh CLEANUP && ./myocsp.sh INIT 
## ./myocsp.sh RESPONDER START
## ./myocsp.sh STAPLING FILE
## cp -pr ocspStapling.crt ocspStapling.key _ocspStapling.resp rootCA.crt /tmp/ocsp/

# 2) setup PG
## git clone git@github.com:idrawone/pg-ocsp.git
## cd pg-ocsp
## ./configure --prefix=/media/david/disk1/pg153 --enable-tap-tests --enable-debug CFLAGS="-g3 -O0 -fno-omit-frame-pointer" CC="gcc -std=gnu99" --with-openssl
## make -j && make install
## cd /tmp
## initdb -D /tmp/pgdata
## append below to postgresql.conf
cat <<EOT >>/tmp/pgdata/postgresql.conf
listen_addresses = '*'
ssl = on
ssl_ca_file = '/tmp/ocsp/rootCA.crt'
ssl_cert_file = '/tmp/ocsp/ocspStapling.crt'
ssl_key_file = '/tmp/ocsp/ocspStapling.key'
ssl_ocsp_file = '/tmp/ocsp/_ocspStapling.resp'
#ssl_min_protocol_version = 'TLSv1.2'
#ssl_max_protocol_version = 'TLSv1.2'
EOT
## pg_ctl -D pgdata -l logfile start

# 3) verify with psql
## cd ocsp
## ./myocsp.sh CREATE user1
## psql "sslmode=verify-ca sslrootcert=rootCA.crt sslcert=user1.crt sslkey=user1.key hostaddr=127.0.0.1 user=david dbname=postgres"
## psql "sslmode=verify-ca sslrootcert=rootCA.crt sslcert=user1.crt sslkey=user1.key hostaddr=127.0.0.1 user=david dbname=postgres host=ocspStapling"

# 4) troubleshooting
## cd ocsp
## openssl ocsp -respin _ocspStapling.resp -issuer rootCA.crt -cert ocspSigning.crt -CAfile rootCA.crt -no_nonce
## openssl ocsp -respin ocsp_resp_stapled_psql.der -issuer rootCA.crt -cert ocspSigning.crt -CAfile rootCA.crt -no_nonce



