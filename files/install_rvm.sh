#!/bin/bash

RVM_RUBY=${1:-2.2.4}
RVM_BRANCH=${2:-stable}
SERVERS=(
    hkp://pgp.mit.edu
    hkp://keys.gnupg.net
)

for server in "${SERVERS[@]}"
do
    gpg --keyserver ${server} --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    success=$?

    if [ "$success" == "0" ]; then
        break
    fi
done
curl -L https://get.rvm.io | grep -v __rvm_print_headline | bash -s $RVM_BRANCH --version 1.29.4 --ruby=$RVM_RUBY --gems=bundler
