# Inspired by https://github.com/jojomi/docker-hugo

FROM klakegg/hugo:latest as binary

ENV HUGO_REFRESH_TIME=60

COPY ./run.sh /run.sh
RUN chmod 0777 /run.sh

VOLUME /source
VOLUME /output

WORKDIR /source
ENTRYPOINT ["/run.sh"]

EXPOSE 1313
