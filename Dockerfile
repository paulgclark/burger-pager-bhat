FROM ubuntu:22.04

# user info
ENV user=sdr
ENV password=snowball

# basic Ubuntu setup
ENV PULSE_SERVER=unix:/var/run/pulseaudio.sock
ENV XDG_RUNTIME_DIR=/tmp
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apt-utils \
    xauth \
    libx11-dev \
    pulseaudio \
    libsndfile1-dev \
    sudo \
    # for debug only; remove for prod
    dbus-x11 \
    xterm \
    alsa-utils \
    pciutils \
    vim \
    # build utils
    cmake \
    git \
    libpcsclite-dev \
    shtool \
    libtalloc-dev \
    gnutls-dev \
    build-essential \
    libtool \
    libtalloc-dev \
    libsctp-dev \
    autoconf \
    automake \
    git-core \
    pkg-config \
    software-properties-common \
    make \
    libmnl-dev \
    python3-pip \
    mlocate \
    usbutils \
    tmux \
    tmuxp \
    binwalk \
    libcap2-bin \
    psmisc \
    unzip \
    wireshark \
    && touch /root/.Xauthority

# expose the port for graphics
EXPOSE 8887

# UHD and GNU Radio
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:gnuradio/gnuradio-releases && \
    DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ettusresearch/uhd && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    python3-gi \
    gobject-introspection \
    gir1.2-gtk-3.0 \
    gnuradio \
    libuhd-dev \
    uhd-host \
    libusb-1.0.0-dev \
    # GNU Radio OOT dependencies \
    libspdlog-dev \
    libboost-all-dev \
    libboost-thread-dev \
    libboost-test-dev \
    libsctp-dev \
    libfftw3-dev \
    liborc-0.4-dev \
    debconf \
    python-setuptools \
    # fosphor dependencies
    intel-opencl-icd \
    gr-fosphor \
    clinfo \
    && sudo uhd_images_downloader
    #&& sudo rm -rf /var/lib/apt/lists/*

# build gr-satellites
#RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:daniestevez/gr-satellites && \
#    DEBIAN_FRONTEND=noninteractive apt-get update && \
#    DEBIAN_FRONTEND=noninteractive apt-get -y install \
#    gr-satellites

# create a user
RUN useradd -m \
    # setup home dir
    -d /home/${user} \
    # set shell to bash
    -s /bin/bash \
    # set uid
    -u 1000 \
    --password '' \
    # this is the actual user name
    ${user} && \
    # add to groups: sudo, audio
    usermod -aG sudo ${user} && \
    usermod -aG video ${user} && \
    usermod -aG audio ${user}

# switch back for build/install
USER ${user}
WORKDIR /home/${user}
RUN mkdir share

# add gr-satellites
RUN pip3 install --user --upgrade construct requests && \
    git clone https://github.com/daniestevez/gr-satellites && \
    cd gr-satellites && \
    git checkout maint-3.10 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    sudo make install && \
    sudo ldconfig

RUN sudo pip3 install --upgrade urh && \
    sudo pip3 install --upgrade numpy

ENV UHD_IMAGES_DIR=/usr/share/uhd/images/

# copy the files needed
COPY xfr_files.tar.gz /home/${user}/.

# go back to user's home directory
WORKDIR /home/${user}

# copy new README and cause it to be printed on login
RUN tar -xvf xfr_files.tar.gz --strip-components 1 && \
    echo 'export PS1="[docker-burger]$PS1"' >> /home/${user}/.bashrc && \
    echo "cat burger-tutorial.txt" >> /home/${user}/.bashrc
