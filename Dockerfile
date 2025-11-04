FROM ubuntu:latest
LABEL authors="xz"

ENTRYPOINT ["top", "-b"]