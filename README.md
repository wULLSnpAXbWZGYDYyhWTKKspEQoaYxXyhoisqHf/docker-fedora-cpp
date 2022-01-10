# docker-fedora-cpp

[![Build Status](https://drone.dotya.ml/api/badges/wanderer/docker-fedora-cpp/status.svg?ref=refs/heads/dev)](https://drone.dotya.ml/wanderer/docker-fedora-cpp)
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/immawanderer/fedora-cpp)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/immawanderer/archlinux/linux-amd64)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated&name=linux-amd64)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/immawanderer/archlinux/linux-amd64)](https://hub.docker.com/r/immawanderer/fedora-cpp/tags/?page=1&ordering=last_updated&name=linux-amd64)
[![Docker pulls](https://img.shields.io/docker/pulls/immawanderer/archlinux)](https://hub.docker.com/r/immawanderer/fedora-cpp/)

This repository provides a Dockerfile to create a container image mainly used for CI testing of C/C++ programs on Fedora.

The image is rebuilt nightly to ensure it always has the latest packages.

development happens on [this Gitea instance](https://git.dotya.ml/wanderer/docker-fedora-cpp)

## What you get
* updated `registry.fedoraproject.org/fedora-minimal:35` image
* the result of
```sh
    microdnf install --nodocs dnf dnf-plugins-core -y && \
    dnf copr enable eddsalkield/iwyu -y && \
    microdnf install --nodocs --setopt install_weak_deps=0 -y \
    git \
    ninja-build \
    make \
    {c,auto}make \
    gcc \
    gcc-c++ \
    libgcc \
    libstdc++-{devel,static} \
    glibc-devel \
    iwyu \
    cryptopp-devel \
    libasan-static \
    liblsan-static \
    libubsan-static \
    libtsan-static \
    binutils \
    lld \
    flex \
    bison \
    openmpi-devel \
    which \
    file \
    grpc-{cli,cpp,devel,plugins} \
    protobuf-c-{devel,compiler} \
    protobuf-compiler \
    cppunit \
    log4cpp-devel \
    json-c-devel \
    capnproto-{devel,libs} \
    libpcap-devel \
    hiredis-devel \
    mongo-c-driver-{devel,libs} \
    boost-{devel,atomic,chrono,date-time,system,program-options,regex,thread} \
    libtool \
    autoconf \
    pkgconf \
    kernel-devel \
    ncurses-{c++-libs,devel,libs,static} \
    numactl-{devel,libs} \
    && dnf copr disable eddsalkield/iwyu \
    && rm -vf /etc/dnf/protected.d/dnf.conf \
    && microdnf remove dnf-plugins-core -y \
    && rpm --nodeps -e dnf \
    && microdnf clean all -y
```
* compiled [`github.com/ntop/nDPI.git`](https://github.com/ntop/nDPI)

## Purpose
* testing c/cpp programs in CI without the need to install all of the deps (such as protobuf, capnproto, pcap, boost, etc...) all the time.  
  found out that if there's enough deps it can actually take more time to pre-configure the environment than downloading a single image once reusing it for all subsequent CI builds.
