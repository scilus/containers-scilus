# syntax=docker/dockerfile:1.4

FROM dmriqcpy-base as dmriqcpy

ARG DMRIQCPY_VERSION
ARG UNINSTALL_VTK

ENV DMRIQCPY_VERSION=${DMRIQCPY_VERSION:-0.1.6}

RUN pip3 install git+https://github.com/scilus/dmriqcpy.git@${DMRIQCPY_VERSION} && \
    sed -i '41s/.*/backend : Agg/' /usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/matplotlibrc && \
    if [[ -n "${UNINSTALL_VTK}" ]] ; then pip3 uninstall -y vtk ; fi
