FROM centos:7

RUN yum install -y epel-release

RUN yum groupinstall development -y

WORKDIR /app/binutils

RUN git clone https://github.com/bminor/binutils-gdb . && git checkout binutils-2_16

RUN ./configure --target=h8500-hms --prefix=/usr/local && make -j20

RUN make install

ENV PATH=/usr/local/h8500-hms/bin:$PATH
