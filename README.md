#### Table of Contents

1. [Overview](#overview)
2. [What katello_devel affects](#what-katello_devel-affects)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

This module is designed to setup a Katello development environment for developing Katello or Foreman in the context of each other.

## What katello_devel affects

* Installs Katello and Foreman from git
* Provides an HTTPS server and proxy to local Rails server for easy use of subscription-manager
* Uses RVM to provide isolated gem environment

## Usage

Please see https://github.com/Katello/katello-installer#development-examples

## Limitations

* EL7 (RHEL7 / CentOS 7)

## Development

See the CONTRIBUTING guide for steps on how to make a change and get it accepted upstream.

