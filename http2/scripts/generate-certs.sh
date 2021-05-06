#!/bin/bash

set -eu

HOME=$(dirname "$0")
FULL_HOME="$(pwd)"/"$HOME"
SERVER=localhost

function generateCA() {
    SUBJECT=$1
    openssl req \
        -nodes \
        -x509 \
        -sha256 \
        -newkey rsa:2048 \
        -subj "$SUBJECT" \
        -days 365 \
        -keyout ca.key \
        -out ca.crt
}

function generateServerCertificate() {
    SUBJECT=$1
    NAME=$2
    openssl req \
        -new \
        -nodes \
        -sha256 \
        -subj "$SUBJECT" \
        -extensions v3_req \
        -reqexts SAN \
        -config <(cat "$FULL_HOME"/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:$SERVER\n")) \
        -keyout "$NAME".key \
        -out "$NAME".csr
        
    openssl x509 \
        -req \
        -sha256 \
        -in "$NAME".csr \
        -CA ca.crt \
        -CAkey ca.key \
        -CAcreateserial \
        -extfile <(cat "$FULL_HOME"/openssl.cnf <(printf "subjectAltName=DNS:$SERVER\n")) \
        -extensions v3_req \
        -out "$NAME".crt \
        -days 365
}

function generateClientCertificate() {
    SUBJECT=$1
    NAME=$2
    openssl req \
        -new \
        -nodes \
        -sha256 \
        -subj "$SUBJECT" \
        -keyout "$NAME".key \
        -out "$NAME".csr

    openssl x509 \
        -req \
        -sha256 \
        -in "$NAME".csr \
        -CA ca.crt \
        -CAkey ca.key \
        -CAcreateserial \
        -out "$NAME".crt \
        -days 365
}

OUTPUT_ROOT=1
OUTPUT_CLIENT=1
OUTPUT_SERVER=1

while getopts 'sc' option
do
    case $option in
        s) OUTPUT_ROOT=0;OUTPUT_SERVER=1;OUTPUT_CLIENT=0 ;;
        c) OUTPUT_ROOT=0;OUTPUT_SERVER=0;OUTPUT_CLIENT=1 ;;
    esac
done

if test "$OUTPUT_ROOT" == 1; then
    generateCA "/C=UK/ST=London/L=London/O=Hummingbird/OU=Examples/CN=${SERVER}"
fi
if test "$OUTPUT_SERVER" == 1; then
    generateServerCertificate "/C=UK/ST=London/L=London/O=Hummingbird/OU=Examples/CN=${SERVER}" server
fi
if test "$OUTPUT_CLIENT" == 1; then
    generateClientCertificate "/C=UK/ST=London/L=London/O=Hummingbird/OU=Examples/CN=${SERVER}" client
fi