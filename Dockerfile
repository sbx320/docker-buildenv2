FROM buildbot/buildbot-worker:master
user root
# wget
RUN apt-get update && apt-get install -y \
	software-properties-common \
	wget

# LLVM packages
RUN /bin/bash -c "echo $'\n\
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main\n\
deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial main\n\
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.8 main\n\
deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.8 main\n\
' >> /etc/apt/sources.list"

# LLVM Key
RUN /usr/bin/wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -


# add toolchain repo
RUN add-apt-repository ppa:ubuntu-toolchain-r/test

# install compilation dependencies
RUN apt-get update && apt-get install -y \
	gcc-4.9 \
	g++-4.9 \
	clang-3.8 \
	clang++-3.8 \
	make \
	libssl-dev

# use clang
ENV CXX="clang++-3.8 -fPIC -std=c++1y"
ENV CC="clang-3.8 -fPIC"
ENV CPP="clang-3.8 -E -fPIC"
ENV LINK="clang++-3.8"
ENV CXX_host="clang++-3.8 -fPIC -std=c++1y"
ENV CC_host="clang-3.8 -fPIC"
ENV CPP_host="clang-3.8 -E -fPIC"
ENV LINK_host="clang++-3.8"

user buildbot
