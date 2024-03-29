# syntax=docker/dockerfile:1.3
FROM registry.fedoraproject.org/fedora-minimal:36

ARG BUILD_DATE
ARG VCS_REF

# as per https://github.com/opencontainers/image-spec/blob/main/annotations.md,
# keep Label Schema labels for backward compatibility.
LABEL description="Container image mainly used for CI testing of C/C++ programs on Fedora" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://git.dotya.ml/wanderer/docker-fedora-cpp.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.license=GPL-3.0 \
      org.opencontainers.image.title="docker-fedora-cpp" \
      org.opencontainers.image.description="Container image mainly used for CI testing of C/C++ programs on Fedora" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.authors=wanderer \
      org.opencontainers.image.url="https://git.dotya.ml/wanderer/docker-fedora-cpp.git" \
      org.opencontainers.image.source="https://git.dotya.ml/wanderer/docker-fedora-cpp.git" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.licenses=GPL-3.0

RUN printf "[main]\ngpg_check=1\ninstallonly_limit=2\nclean_requirements_on_remove=True\nfastestmirror=True\nmax_parallel_downloads=7\n" > /etc/dnf/dnf.conf; \
    cat /etc/dnf/dnf.conf; \
    \
    microdnf --refresh upgrade -y && \
    \
    \
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
    && microdnf clean all -y && \
    \
	\
    printf "/usr/local/lib\n" >> /etc/ld.so.conf.d/local.conf && \
	/usr/sbin/ldconfig && \
    \
	\
    bash -c 'export MAKEFLAGS="$MAKEFLAGS -j$(nproc)" && printf "$MAKEFLAGS\n"; \
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
    make install'; \
	\
    if [ -f /tmp/nDPI/config.log ]; then cat /tmp/nDPI/config.log; fi; \
    rm -rf /tmp/nDPI

# nDPI is by default (left unchanged) installed with prefix "/usr/local".
# we make sure the results (libs in /usr/local/lib) get picked up in subsequent
# linkings against it by aappending to /etc/ld.so.conf.d/local.conf.
# see https://git.dotya.ml/wanderer/docker-fedora-cpp/issues/1
#
# further, building nDPI would fail with plain RUN inside kaniko.
# having it wrapped in 'bash -c' helped
