# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.12

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
RUN apt-get update && apt-get install -y \
  cups \
  vim \
  wget

RUN useradd papercut
RUN mkdir /home/papercut && chown -R papercut: /home/papercut
USER papercut
WORKDIR /home/papercut
RUN wget http://cdn.papercut.com/anonftp/pub/pcng/14.x/pcng-setup-14.2.27858-linux-x64.sh
RUN sh pcng-setup-14.2.27858-linux-x64.sh -e
RUN rm /home/papercut/papercut/LICENCE.TXT
RUN sed -i 's/read reply leftover//g' papercut/install
RUN sed -i 's/answered=/answered=0/g' papercut/install
ENV HOME /home/papercut
RUN papercut/install
USER root
RUN ${HOME}/server/bin/linux-x64/roottasks
RUN ${HOME}/providers/print/linux-x64/roottasks
RUN ${HOME}/providers/web-print/linux-x64/roottasks
RUN mkdir -p /etc/my_init.d
ADD run.sh /etc/my_init.d/run.sh
EXPOSE 9191

VOLUME /home/papercut/server/data
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
