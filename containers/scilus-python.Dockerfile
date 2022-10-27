# syntax=docker/dockerfile:1.4

FROM python-base AS scilus-python

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
        python3-pip \
        python3.7 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1 && \
    update-alternatives --config python3 && \
    update-alternatives  --set python3 /usr/bin/python3.7 && \
    python3.7 -m pip install pip && \
    pip3 install --upgrade pip && \
    pip3 install -U setuptools && \
    apt-get -y install \
        python3-lxml \
        python3-six \
        python3.7-dev \
        python3.7-tk && \
    rm -rf /var/lib/apt/lists/*

ENV PYTHON_INCLUDE_DIR=/usr/include/python3.7
ENV PYTHON_LIBS=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7.so
ENV PYTHON_LIBRARY=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7.so
