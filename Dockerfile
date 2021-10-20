# syntax=docker/dockerfile:1.3
FROM registry.fedoraproject.org/fedora-minimal:34

ARG BUILD_DATE
ARG VCS_REF

LABEL description="Container image mainly used for CI testing of C/C++ programs on Fedora"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://git.dotya.ml/wanderer/docker-fedora-cpp.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.license=GPL-3.0

RUN printf "[main]\ngpg_check=1\ninstallonly_limit=2\nclean_requirements_on_remove=True\nfastestmirror=True\nmax_parallel_downloads=7\n" > /etc/dnf/dnf.conf; \
    cat /etc/dnf/dnf.conf; \
    microdnf --refresh upgrade -y
RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    git \
    ninja-build \
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
    && microdnf clean all -y

# nDPI will by default (left unchanged) be installed with prefix "/usr/local".
# this makes sure the results get picked up in subsequent linkings against it.
RUN printf "/usr/local/lib\n" >> /etc/ld.so.conf.d/local.conf && /usr/sbin/ldconfig

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

