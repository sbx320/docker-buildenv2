FROM sbx320/buildenv2

user root

ADD . /compat

ENV SSL_VER=1.0.2j \
    PREFIX=/usr/local \
    PATH=/usr/local/bin:$PATH

RUN curl -sL http://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xz && \
    cd openssl-$SSL_VER && \
    ./Configure no-shared --prefix=$PREFIX --openssldir=$PREFIX/ssl no-zlib linux-x86_64 && \
    make depend 2> /dev/null && make -j$(nproc) && make install && \
    cd .. && rm -rf openssl-$SSL_VER

ENV OPENSSL_LIB_DIR=$PREFIX/lib \
    OPENSSL_INCLUDE_DIR=$PREFIX/include \
    OPENSSL_DIR=$PREFIX \
    OPENSSL_STATIC=1

RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/lib/gcc/x86_64-linux-gnu/5/libstdc++.a /compat/libstdc++.a
RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/local/lib/libssl.a /compat/libssl.a
RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/local/lib/libcrypto.a /compat/libcrypto.a

ENV CXX="clang++-3.8 -fPIC -std=c++1y -i/compat/glibc_version.h -L/compat"
ENV CC="clang-3.8 -fPIC -L/compat"
ENV CPP="clang-3.8 -E -fPIC -L/compat"
ENV LINK="clang++-3.8 -static-libstdc++ -static-libgcc -L/compat"

user buildbot 
