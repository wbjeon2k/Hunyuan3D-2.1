FROM ubuntu:24.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y lubuntu-desktop && \
    DEBIAN_FRONTEND=noninteractive apt install -y xrdp && \
    DEBIAN_FRONTEND=noninteractive apt install -y openssh-server && \
    DEBIAN_FRONTEND=noninteractive apt install -y dbus-x11 && \
    DEBIAN_FRONTEND=noninteractive apt install -y blender && \
    adduser xrdp ssl-cert

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb

RUN useradd -m test && \
    echo "test:ubuntu" | chpasswd && \
    usermod -aG sudo test

RUN echo "lxqt-session" > /home/test/.xsession && \
    chown test:test /home/test/.xsession && \
    chmod +x /home/test/.xsession

RUN sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini

EXPOSE 3390

CMD ["/bin/bash", "-c", "service dbus start && service xrdp start && tail -f /dev/null"]

# docker run -d --privileged --gpus=all --shm-size=16G -p 3390:3390 -v C:\GitRepo\Hunyuan3D-2.1:/home/test --name xrdptest1 lubuntudesktop:0.0

# Blender/ Scripting workspace
# import sys
# print(sys.executable)