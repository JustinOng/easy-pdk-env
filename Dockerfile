FROM ubuntu:focal AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  subversion build-essential libboost-all-dev bison flex texinfo ca-certificates unzip \
  && rm -rf /var/lib/apt/lists/*

ARG SDCC_SVN_REVISION=12752
ARG EASY_PDK_VER=20200713_1.3

RUN svn checkout -r ${SDCC_SVN_REVISION} svn://svn.code.sf.net/p/sdcc/code/trunk sdcc
RUN cd sdcc/sdcc && \
  ./configure --disable-ds390-port --disable-ds400-port --disable-hc08-port --disable-s08-port --disable-mcs51-port --disable-pic14-port --disable-pic16-port --disable-z80-port --disable-z180-port --disable-r2k-port --disable-r2ka-port --disable-r3ka-port --disable-gbz80-port --disable-tlcs90-port --disable-ez80_z80-port --disable-z80n-port --disable-stm8-port &&\
  make && make install

ADD https://github.com/free-pdk/easy-pdk-programmer-software/releases/download/1.3/EASYPDKPROG_LINUX_${EASY_PDK_VER}.zip ./
RUN unzip EASYPDKPROG_LINUX_${EASY_PDK_VER}.zip

FROM ubuntu:focal

RUN apt-get update && apt-get install -y --no-install-recommends \
  make gawk\
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/* /usr/local/bin/
COPY --from=build /usr/local/share/sdcc/ /usr/local/share/sdcc/
COPY --from=build /EASYPDKPROG/easypdkprog /usr/local/sbin/
