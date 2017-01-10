FROM buildbot/buildbot-worker:master
user root
RUN apt-get update && apt-get install -y \
	software-properties-common \
	wget

ADD . /compat

# add toolchain repo
RUN add-apt-repository ppa:ubuntu-toolchain-r/test

# install compilation dependencies
RUN apt-get update && apt-get install -y \
	gcc-6 \
	g++-6 \
	clang-3.8 \
	clang++-3.8 \
	make \
	libssl-dev && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV SSL_VER=1.0.2j \
    PREFIX=/usr/local \
    PATH=/usr/local/bin:$PATH

ENV CC="clang-3.8 -fPIC"

RUN curl -sL http://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xz && \
    cd openssl-$SSL_VER && \
    ./Configure no-shared --prefix=$PREFIX --openssldir=$PREFIX/ssl no-zlib linux-x86_64 && \
    make depend 2> /dev/null && make -j$(nproc) && make install && \
    cd .. && rm -rf openssl-$SSL_VER

ENV OPENSSL_LIB_DIR=$PREFIX/lib \
    OPENSSL_INCLUDE_DIR=$PREFIX/include \
    OPENSSL_DIR=$PREFIX \
    OPENSSL_STATIC=1

ENV CXX="clang++-3.8 -fPIC -std=c++1z -i/compat/glibc_version.h"
ENV CC="clang-3.8 -fPIC -i/compat/glibc_version.h"
ENV CPP="clang-3.8 -E"
ENV LINK="clang++-3.8 -static-libstdc++ -static-libgcc -L/compat"
	
RUN add-apt-repository ppa:ubuntu-toolchain-r/test 

RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/lib/gcc/x86_64-linux-gnu/6/libstdc++.a /compat/libstdc++.a
RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/lib/gcc/x86_64-linux-gnu/6/libstdc++fs.a /compat/libstdc++fs.a
RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/local/lib/libssl.a /compat/libssl.a
RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/local/lib/libcrypto.a /compat/libcrypto.a

RUN wget https://github.com/sbx320/binaries/blob/master/dump_syms?raw=true -O /usr/bin/dump_syms && chmod +x /usr/bin/dump_syms

user buildbot 
RUN mkdir ~/.ssh
RUN ssh-keyscan -H gitlab.nanos.io >> ~/.ssh/known_hosts


CMD cp /id_rsa ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa && \
   /usr/local/bin/dumb-init twistd -ny buildbot.tac

