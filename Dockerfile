FROM rakudo-star

WORKDIR /app

RUN apt-get update -y && \
  apt-get install -y build-essential libssl-dev libgpgme-dev wget && \
  zef install WWW Colorizable GPGME --force-test

CMD [ "./scripts/install.sh" ]
