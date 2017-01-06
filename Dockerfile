FROM sbx320/buildenv2

user root

ADD . /compat

RUN objcopy --redefine-syms=/compat/glibc_version.redef /usr/lib/gcc/x86_64-linux-gnu/5/libstdc++.a /compat/libstdc++.a
#RUN objcopy --redefine-syms=/compat/glibc_version.redef /lib/x86_64-linux-gnu/libssl.a /compat/libssl.a

ENV CXX="clang++-3.8 -fPIC -std=c++1y -i/compat/glibc_version.h -L/compat"
ENV CC="clang-3.8 -fPIC -L/compat"
ENV CPP="clang-3.8 -E -fPIC -L/compat"
ENV LINK="clang++-3.8 -static-libstdc++ -static-libgcc -L/compat"

user buildbot 
