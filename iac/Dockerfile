FROM google/cloud-sdk:latest

WORKDIR /app

ENV TERRAFORM_BIN_ZIP https://releases.hashicorp.com/terraform/1.2.3/terraform_1.2.3_linux_amd64.zip

RUN apt-get update && \
    apt-get install -y unzip google-cloud-sdk-config-connector

RUN curl -fsSL $TERRAFORM_BIN_ZIP --output terraform_bin.zip && \
    unzip terraform_bin.zip && \
    rm terraform_bin.zip && \
    cp terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform
