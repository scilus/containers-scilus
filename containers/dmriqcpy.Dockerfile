# syntax=docker/dockerfile:1.4

FROM dmriqcpy-base as dmriqcpy

ARG DMRIQCPY_VERSION
ENV DMRIQCPY_VERSION=${DMRIQCPY_VERSION:-0.1.6}
ARG PYTHON_VERSION
ENV PYTHON_VERSION=${PYTHON_VERSION:-3.7}
ARG VTK_VERSION
ENV VTK_VERSION=${VTK_VERSION:-8.2.0}
ARG VTK_INSTALL_PATH
ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}

WORKDIR /
RUN python${PYTHON_VERSION} -m pip install git+https://github.com/scilus/dmriqcpy.git@${DMRIQCPY_VERSION} && \
    python${PYTHON_VERSION} -m pip cache purge && \
    sed -i '41s/.*/backend : Agg/' /usr/local/lib/python${PYTHON_VERSION}/site-packages/matplotlib/mpl-data/matplotlibrc

WORKDIR ${VTK_INSTALL_PATH}
RUN PYTHON_MAJOR=${VTK_PYTHON_VERSION%%.*} && \
    python${PYTHON_VERSION} -m pip install vtk-${VTK_VERSION}-py${PYTHON_MAJOR}-none-any.whl

WORKDIR /
RUN touch VERSION && \
    echo "dMRIqcpy => ${DMRIQCPY_VERSION}\n" >> VERSION
