FROM ubuntu:18.04
LABEL maintainer="Frank Carta <fcarta@vmware.com>"

# Install System libraries
RUN echo "Installing System Libraries" \
  && apt-get update \
  && apt-get install -y build-essential python3.6 python3-pip python3-dev groff bash-completion git curl unzip wget findutils jq vim tree docker.io

# Install Carvel tools
RUN echo "Installing K14s Carvel tools" \
  && wget -O- https://carvel.dev/install.sh | bash