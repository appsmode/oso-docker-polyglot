# syntax=docker/dockerfile:1.3-labs
# This Dockerfile is using heredocs syntax https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/, so ensure you've got
# an up-to-date Docker version with buildkit support
FROM rust:latest
MAINTAINER Alex Hafner
ARG GO_VERSION=1.17
ARG NODE_VERSION=16
ARG GO_INSTALL_FILE=go${GO_VERSION}.linux-amd64.tar.gz
ENV OSO_HOME="/root"
ENV OSO_GIT_HOME="${OSO_HOME}/git/oso"
WORKDIR ${OSO_HOME}

# Package/library installation
RUN <<EOF
# Update O/S and install packages
apt-get update -y
# Install Node 16 Nodesource repo
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash
# Install O/S Packages: Languages and supporting libraries
# jq is a JSON processor used for formatting
# maven is used for Java buids
# pip is the python installer
# venv isolates the project python environment from other python installations, particularly the system installation
apt-get install -y default-jdk jq maven  nodejs python3 python3-pip python3-venv ruby-full
# Add WASM Pack for WebAssembly
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
EOF
# Prepare O/S
COPY .oso_functions.sh .
RUN mkdir git
# Javascript specific:
# Add yarn
RUN npm install --global yarn
# Python specific Actions
RUN <<EOF
# Initialize virtual environment
python3 -m venv ./venvs/oso
# Activate new virtual environment
. ./venvs/oso/bin/activate
# Add libraries
pip3 install --no-cache-dir pytest setuptools
EOF
# Ruby specific
# Add Bundler
RUN gem install bundler
# GO specific
# Install GO - requires a minimum of 1.12
RUN <<EOF
rm -rf /usr/local/go
curl https://dl.google.com/go/${GO_INSTALL_FILE} -o ${GO_INSTALL_FILE} -s
tar -C /usr/local -xzf ${GO_INSTALL_FILE}
rm ${GO_INSTALL_FILE}
EOF
# Update .profile
RUN cat <<EOF >>~/.profile
# source oso-specific convenience functions
source .oso_functions.sh
# Add go to system-wide path
export PATH=/usr/local/go/bin:$PATH
# Activate Python venv
source ./venvs/oso/bin/activate

EOF
CMD ["bash", "-l"]
