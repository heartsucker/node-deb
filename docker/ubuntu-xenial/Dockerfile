FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y fakeroot jq && \
    rm -rf /var/lib/apt/lists/*

COPY fake-nodejs.sh /
RUN /fake-nodejs.sh
RUN rm -rf /fake-nodejs.sh /tmp

CMD ["bash"]
