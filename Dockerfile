FROM swiftdocker/swift:3.0.2

# Put the maintainer name in the image metadata
MAINTAINER Gustavo Perdomo <gperdomor@gmail.com>

# Install MySQL
RUN apt-get -yq update && \
    apt-get -yq install libmysqlclient20 libmysqlclient-dev

# Clean APT cache
RUN apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# vapor specific part
WORKDIR /vapor
VOLUME /vapor
EXPOSE 8080

# mount in local sources via:  -v $(PWD):/vapor
# the vapor CLI command does this
CMD swift build -c release && .build/release/App
