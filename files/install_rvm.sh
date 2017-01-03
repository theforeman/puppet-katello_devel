#!/bin/bash

RVM_RUBY=${1:-2.2.4}
RVM_BRANCH=${2:-stable}
SERVERS=(
    hkp://pgp.mit.edu
    hkp://keys.gnupg.net
)

for server in "${SERVERS[@]}"
do
    gpg --keyserver ${server} --recv-keys D39DC0E3
    success=$?

    if [ "$success" == "0" ]; then
        break
    fi
done
curl -L https://get.rvm.io | grep -v __rvm_print_headline | bash -s $RVM_BRANCH --ruby=$RVM_RUBY --gems=bundler
