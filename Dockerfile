# syntax=docker/dockerfile:1.2
FROM registry.fedoraproject.org/fedora:34

ARG BUILD_DATE
ARG VCS_REF

LABEL description="Container image mainly used for CI testing of C/C++ programs on Fedora"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://git.dotya.ml/wanderer/docker-fedora-cpp.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.license=GPL-3.0

RUN dnf --refresh upgrade -y \
    && dnf install --nodocs -y \
    git \
    make \
    {c,auto}make \
    gcc \
    gcc-c++ \
    libgcc \
    libstdc++-{devel,static} \
    glibc-devel \
    binutils \
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
    && dnf clean all -y

# see https://git.dotya.ml/wanderer/docker-fedora-cpp/issues/1
#
# building nDPI would fail with plain RUN and kaniko.
# having it wrapped in 'bash -c' helped
RUN bash -c 'export MAKEFLAGS="$MAKEFLAGS -j$(nproc)" && printf "$MAKEFLAGS\n"; \
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/sbin:$PATH"; \
    git clone https://github.com/ntop/nDPI.git /tmp/nDPI && \
    cd /tmp/nDPI ; \
    git checkout 1.7; \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    git switch - ; \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install'
RUN if [ -f /tmp/nDPI/config.log ]; then cat /tmp/nDPI/config.log; fi; \
    rm -rf /tmp/nDPI

