FROM openkbs/jdk-mvn-py3-x11

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

#### ---- Build Specification ----
# Metadata params
ARG BUILD_DATE=${BUILD_DATE:-}
ARG VERSION=${BUILD_DATE:-}
ARG VCS_REF=${BUILD_DATE:-}

#### ---- Product Specifications ----
ARG PRODUCT=${PRODUCT:-}
ARG PRODUCT_VERSION=${PRODUCT_VERSION:-}
ARG PRODUCT_DIR=${PRODUCT_DIR:-}
ARG PRODUCT_EXE=${PRODUCT_EXE:-}
ENV PRODUCT=${PRODUCT}
ENV PRODUCT_VERSION=${PRODUCT_VERSION}
ENV PRODUCT_DIR=${PRODUCT_DIR}
ENV PRODUCT_EXE=${PRODUCT_EXE}

# Metadata
LABEL org.label-schema.url="https://openkbs.org/" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-url="https://github.com/microscaling/imagelayers-graph.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.description="This utility provides a docker template files for building Docker." \
      org.label-schema.url="https://openkbs.org/" \
      org.label-schema.schema-version="1.0"
      
#### --- Copy Entrypoint script in the container ---- ####
COPY ./docker-entrypoint.sh /

#### ------------------------
#### ---- user: Non-Root ----
#### ------------------------

ENV USER=${USER:-developer}
ENV USER_NAME=${USER}

ENV HOME=/home/${USER}

RUN mkdir -p ${HOME}/workspace && \
    chown ${USER}:${USER} -R ${HOME}/workspace

WORKDIR ${HOME}

USER ${USER}

#### --- Enterpoint for container ---- ####
USER ${USER_NAME}
WORKDIR ${HOME}

#ENTRYPOINT ["/usr/local/docker-entrypoint.sh"]
#CMD ["/usr/bin/firefox"]
# CMD ["/usr/bin/google-chrome","--no-sandbox","--disable-gpu", "--disable-extensions"]
CMD ["/usr/bin/google-chrome"]

# -- test --
#CMD xeyes

#### (Test only)
#CMD ["/bin/bash"]

