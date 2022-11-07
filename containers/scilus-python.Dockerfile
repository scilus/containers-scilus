# syntax=docker/dockerfile:1.4

FROM python-base AS scilus-python

ARG PYTHON_VERSION

ENV PYTHON_PACKAGE_DIR=${PYTHON_PACKAGE_DIR:-dist-packages}
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.7}

WORKDIR /
RUN export PYTHON_MAJOR=${PYTHON_VERSION%%.*} && \
    if [ "$PYTHON_MAJOR" = "3" ]; then export PYTHON_MOD=3; fi && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
        python${PYTHON_MOD}-pip \
        python${PYTHON_VERSION} && \
    update-alternatives --install /usr/bin/python${PYTHON_MOD} python${PYTHON_MOD} /usr/bin/python${PYTHON_VERSION} 1 && \
    update-alternatives --config python${PYTHON_MOD} && \
    update-alternatives  --set python${PYTHON_MOD} /usr/bin/python${PYTHON_VERSION} && \
    python${PYTHON_VERSION} -m pip install pip && \
    pip${PYTHON_MOD} install --upgrade pip && \
    pip${PYTHON_MOD} install -U setuptools && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        python${PYTHON_MOD}-lxml \
        python${PYTHON_MOD}-six \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-tk && \
    rm -rf /var/lib/apt/lists/*

ENV PYTHON_INCLUDE_DIR=/usr/include/python${PYTHON_VERSION}
ENV PYTHON_LIBS=/usr/lib/python${PYTHON_VERSION}/config-${PYTHON_VERSION}m-x86_64-linux-gnu/libpython${PYTHON_VERSION}.so
ENV PYTHON_LIBRARY=${PYTHON_LIBS}

WORKDIR /
RUN touch VERSION && \
    echo "Python => ${PYTHON_VERSION}\n" >> VERSION
