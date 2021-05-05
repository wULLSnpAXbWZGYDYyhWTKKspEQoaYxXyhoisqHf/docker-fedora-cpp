# docker-fedora-cpp

[![Build Status](https://drone.dotya.ml/api/badges/wanderer/docker-fedora-cpp/status.svg?ref=refs/heads/dev)](https://drone.dotya.ml/wanderer/docker-fedora-cpp)
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/immawanderer/fedora-cpp)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/immawanderer/archlinux/linux-amd64)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated&name=linux-amd64)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/immawanderer/archlinux/linux-amd64)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated&name=linux-amd64)
[![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/immawanderer/archlinux/linux-amd64)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated&name=linux-amd64)
[![Docker pulls](https://img.shields.io/docker/pulls/immawanderer/archlinux)](https://hub.docker.com/r/immawanderer/fedora-cpp/)

This repository provides a Dockerfile to create a container image mainly used for CI testing of C/C++ programs on Fedora.

The image is rebuilt nightly to ensure it always has the latest packages.

development happens on [this Gitea instance](https://git.dotya.ml/wanderer/docker-fedora-cpp)

## What you get
* updated `registry.fedoraproject.org/fedora:34` image
* the result of
```sh
dnf install -y make {c,auto}make autoconf lld binutils gcc gcc-c++ libgcc libstdc++-{devel,static} glibc-devel openmpi-devel bison flex grpc-{cli,cpp,devel,plugins} protobuf-c-{devel,compiler} protobuf-compiler cppunit log4cpp-devel json-c-devel capnproto-{devel,libs} libpcap-devel hiredis-devel mongo-c-driver-{devel,libs} boost-{devel,atomic,chrono,date-time,system,program-options,regex,thread} libtool libtool-ltdl which pkgconf openssl-devel kernel-devel ncurses-{c++-libs,devel,libs,static} && dnf clean all -y
```
* compiled `github.com/ntop/nDPI.git`

## Purpose
* testing c/cpp programs in CI without the need to install all of the deps (such as protobuf, capnproto, pcap, boost, etc...) all the time  
  found out that if there's enough deps it actually takes more time to pre-configure the environment than if a single image is downloaded once and reused (this one in drone CI) for all subsequent builds
