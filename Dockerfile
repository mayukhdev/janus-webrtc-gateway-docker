FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get -y update && apt-get install -y \
    libjansson-dev \
    libnice-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
     libcurl4-openssl-dev \
    libini-config-dev \
    libcollection-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    autopoint \
    automake \
    build-essential \
    subversion \
    git \
    cmake \
    unzip \
    zip \
    lsof wget vim sudo rsync cron mysql-client openssh-server supervisor locate mplayer valgrind certbot curl dnsutils tcpdump gstreamer1.0-tools




# FFmpeg build section
RUN mkdir ~/ffmpeg_sources

RUN apt-get update && \
    apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
    libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev

RUN YASM="1.3.0" && cd ~/ffmpeg_sources && \
    wget http://www.tortall.net/projects/yasm/releases/yasm-$YASM.tar.gz && \
    tar xzvf yasm-$YASM.tar.gz && \
    cd yasm-$YASM && \
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"  && \
    make && \
    make install && \
    make distclean

RUN VPX="v1.8.1" && cd ~/ffmpeg_sources && \
    wget https://chromium.googlesource.com/webm/libvpx/+archive/$VPX.tar.gz && \
    tar xzvf $VPX.tar.gz && \
    pwd \
    cd $VPX && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make clean


RUN OPUS="1.3" && cd ~/ffmpeg_sources && \
    wget https://archive.mozilla.org/pub/opus/opus-$OPUS.tar.gz && \
    tar xzvf opus-$OPUS.tar.gz && \
    cd opus-$OPUS && \
    ./configure --help && \
    ./configure --prefix="$HOME/ffmpeg_build"  && \
    make && \
    make install && \
    make clean


RUN LAME="3.100" && apt-get install -y nasm  && cd ~/ffmpeg_sources && \
    wget http://downloads.sourceforge.net/project/lame/lame/$LAME/lame-$LAME.tar.gz && \
    tar xzvf lame-$LAME.tar.gz && \
    cd lame-$LAME && \
    ./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared && \
    make && \
    make install

RUN X264="20181001-2245-stable" && cd ~/ffmpeg_sources && \
    wget http://download.videolan.org/pub/x264/snapshots/x264-snapshot-$X264.tar.bz2 && \
    tar xjvf x264-snapshot-$X264.tar.bz2 && \
    cd x264-snapshot-$X264 && \
    PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --disable-opencl --disable-asm && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean

RUN FDK_AAC="2.0.1" && cd ~/ffmpeg_sources && \
    wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/archive/v$FDK_AAC.tar.gz && \
    tar xzvf fdk-aac.tar.gz && \
    cd fdk-aac-$FDK_AAC && \
    autoreconf -fiv && \
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && \
    make && \
    make install && \
    make distclean

RUN FFMPEG_VER="n4.2.1" && cd ~/ffmpeg_sources && \
    wget https://github.com/FFmpeg/FFmpeg/archive/$FFMPEG_VER.zip && \
    unzip $FFMPEG_VER.zip

RUN FFMPEG_VER="n4.2.1" && cd ~/ffmpeg_sources && \
    cd FFmpeg-$FFMPEG_VER && \
    PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --bindir="$HOME/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-nonfree \
    --enable-libxcb \
    --enable-libpulse \
    --enable-alsa && \
    PATH="$HOME/bin:$PATH" make && \
    make install && \
    make distclean && \
    hash -r && \
    mv ~/bin/ffmpeg /usr/local/bin/




# RUN apt-get update -y && apt-get install -y libssl-dev
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        libc6-dev \
        make \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*
ENV GOLANG_VERSION 1.20.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"


RUN LIBWEBSOCKET="4.3.2" && wget https://github.com/warmcat/libwebsockets/archive/v$LIBWEBSOCKET.tar.gz && \
    tar xzvf v$LIBWEBSOCKET.tar.gz && \
    cd libwebsockets-$LIBWEBSOCKET && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" -DLWS_MAX_SMP=1 -DLWS_IPV6="ON" .. && \
    make && make install


RUN SRTP="2.2.0" && wget https://github.com/cisco/libsrtp/archive/v$SRTP.tar.gz && \
    tar xfv v$SRTP.tar.gz && \
    cd libsrtp-$SRTP && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library && sudo make install



#  2022/01   commit 3d9cae16a5094aadb1651572644cb5786a8b4e2d
RUN apt-get remove -y libnice-dev libnice10 && apt-get update -y && apt-get install -y python3-pip ninja-build  && pip3 install meson && \
    git clone https://gitlab.freedesktop.org/libnice/libnice.git && \
    cd libnice && \
    git checkout 3d9cae16a5094aadb1651572644cb5786a8b4e2d && \
    meson --prefix=/usr build && \
    ninja -C build && \
    sudo ninja -C build install



# datachannel build
RUN cd / && git clone https://github.com/sctplab/usrsctp && \
cd usrsctp && \
./bootstrap && \
./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && \
make && sudo make install

# libmicrohttpd
WORKDIR /tmp
RUN git clone https://git.gnunet.org/libmicrohttpd.git
WORKDIR /tmp/libmicrohttpd
RUN git checkout v0.9.60 && autoreconf -fi && ./configure && \
make && make install


# janus
RUN cd / && git clone https://github.com/meetecho/janus-gateway.git && cd /janus-gateway && \
    git checkout refs/tags/v1.1.4 && \
    sh autogen.sh &&  \
    ./configure && \
    make && make install && make configs

COPY nginx.conf /usr/local/nginx/nginx.conf


ENV NODE_VERSION 16.20.1
ENV NVM_DIR /usr/local/nvm
RUN mkdir $NVM_DIR
RUN cd / && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash 

SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]

CMD nginx && janus
