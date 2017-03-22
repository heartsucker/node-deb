FROM debian:wheezy

# TODO remove ?
RUN echo deb http://ftp.de.debian.org/debian wheezy-backports main >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y fakeroot jq && \
    rm -rf /var/lib/apt/lists/*

COPY fake-nodejs.sh /
RUN /fake-nodejs.sh
RUN rm -rf /fake-nodejs.sh /tmp

CMD ["bash"]
