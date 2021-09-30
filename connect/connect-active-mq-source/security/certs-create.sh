#!/bin/bash

#set -o nounset \
#    -o errexit \
#    -o verbose \
#    -o xtrace

# Cleanup files
rm -f *.crt *.csr *_creds *.jks *.srl *.key *.pem *.der *.p12 extfile

if [[ "$OSTYPE" == "darwin"* ]]
then
    # workaround for issue on linux, see https://github.com/vdesabou/kafka-docker-playground/issues/851#issuecomment-821151962
    chmod -R a+rw .
else
    # workaround for issue on linux, see https://github.com/vdesabou/kafka-docker-playground/issues/851#issuecomment-821151962
    sudo chmod -R a+rw .
fi
# Generate CA key
docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9 openssl req -new -x509 -keyout /tmp/snakeoil-ca-1.key -out /tmp/snakeoil-ca-1.crt -days 365 -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/ST=Ca/C=US' -passin pass:confluent -passout pass:confluent

for i in connect activemq
do
    echo "------------------------------- $i -------------------------------"

    # Create host keystore
    docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9 keytool -genkey -noprompt \
                 -alias $i \
                 -dname "CN=$i,OU=TEST,O=CONFLUENT,L=PaloAlto,S=Ca,C=US" \
                                 -ext "SAN=dns:$i,dns:localhost" \
                 -keystore /tmp/kafka.$i.keystore.jks \
                 -keyalg RSA \
                 -storepass confluent \
                 -keypass confluent \
                 -storetype pkcs12

    # Create the certificate signing request (CSR)
    docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9 keytool -keystore /tmp/kafka.$i.keystore.jks -alias $i -certreq -file /tmp/$i.csr -storepass confluent -keypass confluent -ext "SAN=dns:$i,dns:localhost"
        #openssl req -in $i.csr -text -noout

cat << EOF > extfile
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
CN = $i
[v3_req]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $i
DNS.2 = localhost
EOF
        # Sign the host certificate with the certificate authority (CA)
        docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9 openssl x509 -req -CA /tmp/snakeoil-ca-1.crt -CAkey /tmp/snakeoil-ca-1.key -in /tmp/$i.csr -out /tmp/$i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:confluent -extensions v3_req -extfile /tmp/extfile

        #openssl x509 -noout -text -in $i-ca1-signed.crt

        # Sign and import the CA cert into the keystore
    docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9 keytool -noprompt -keystore /tmp/kafka.$i.keystore.jks -alias CARoot -import -file /tmp/snakeoil-ca-1.crt -storepass confluent -keypass confluent
        #keytool -list -v -keystore kafka.$i.keystore.jks -storepass confluent

        # Sign and import the host certificate into the keystore
    docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9  keytool -noprompt -keystore /tmp/kafka.$i.keystore.jks -alias $i -import -file /tmp/$i-ca1-signed.crt -storepass confluent -keypass confluent -ext "SAN=dns:$i,dns:localhost"
        #keytool -list -v -keystore kafka.$i.keystore.jks -storepass confluent

    # Create truststore and import the CA cert
    docker run --rm -v $PWD:/tmp rmohr/activemq:5.15.9  keytool -noprompt -keystore /tmp/kafka.$i.truststore.jks -alias CARoot -import -file /tmp/snakeoil-ca-1.crt -storepass confluent -keypass confluent

    # Save creds
      echo  "confluent" > ${i}_sslkey_creds
      echo  "confluent" > ${i}_keystore_creds
      echo  "confluent" > ${i}_truststore_creds
done
