from centos:7

run yum install -y epel-release

run yum groupinstall development -y

workdir /root/binutils

run git clone https://github.com/bminor/binutils-gdb . && git checkout binutils-2_16

run ./configure --target=h8500-hms && make -j20
