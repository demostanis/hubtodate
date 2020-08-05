FROM rakudo-star

WORKDIR /app

RUN apt-get update -y && \
  apt-get install -y build-essential libssl-dev wget && \
  zef install WWW Colorizable UNIX::Privileges --force-test

CMD [ "./scripts/install.sh" ]
