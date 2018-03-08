FROM ruby:1.9

EXPOSE 9292

WORKDIR /pg_web_stats
COPY . /pg_web_stats/
RUN set -ex; \
    mkdir /etc/pg_web_stats; \
    ln -sf /etc/pg_web_stats/config.yml /pg_web_stats/config.yml; \
    bundle install

CMD ["rake", "server"]
