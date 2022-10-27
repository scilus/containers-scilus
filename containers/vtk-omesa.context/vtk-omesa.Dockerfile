# syntax=docker/dockerfile:1.4

FROM vtk-builder as vtk

ARG MESA_INSTALL_PATH
ARG MESA_VERSION
ARG VTK_BUILD_PATH
ARG VTK_INSTALL_PATH
ARG VTK_PYTHON_VERSION
ARG VTK_VERSION

ENV MESA_INSTALL_PATH=${MESA_INSTALL_PATH:-/mesa}
ENV MESA_VERSION=${MESA_VERSION:-19.0.8}
ENV VTK_BUILD_PATH=${VTK_BUILD_PATH:-/vtk_build}
ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}
ENV VTK_PYTHON_VERSION=${VTK_PYTHON_VERSION:-3.7}
ENV VTK_VERSION=${VTK_VERSION:-8.2.0}

WORKDIR /
RUN if [ "${VTK_PYTHON_VERSION%%.*}" = "3" ]; then export PYTHON_MAJOR=3; fi && \
    mkdir ${MESA_INSTALL_PATH} ${VTK_INSTALL_PATH} ${VTK_BUILD_PATH} && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        build-essential \
        gcc \
        git \
        llvm-7 \
        llvm-7-dev \
        llvm-7-runtime \
        libboost-all-dev \
        libopenmpi-dev \
        python${PYTHON_MAJOR}-pip \
        python${VTK_PYTHON_VERSION} \
        python${VTK_PYTHON_VERSION}-dev \
        clang \
        wget \
        xorg-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN wget https://archive.mesa3d.org/mesa-${MESA_VERSION}.tar.gz && \
    tar -xzf mesa-${MESA_VERSION}.tar.gz && \
    rm mesa-${MESA_VERSION}.tar.gz

WORKDIR /mesa-${MESA_VERSION}
RUN ./configure --prefix=${MESA_INSTALL_PATH} \
                --enable-autotools \
                --enable-gallium-llvm \
                --enable-gallium-osmesa \
                --enable-llvm-shared-libs \
                --enable-opengl \
                --enable-shared-glapi \
                --disable-dri \
                --disable-egl \
                --disable-gbm \
                --disable-gles1 \
                --disable-gles2 \
                --disable-glx \
                --disable-osmesa \
                --disable-va \
                --disable-vdpau \
                --disable-texture-float \
                --disable-xvmc \
                --with-dri-drivers= \
                --with-egl-platforms= \
                --with-gallium-drivers=swrast,swr \
                --with-llvm-prefix=/usr/lib/llvm-7 && \
    make -j $(nproc --all) && \
    make install

WORKDIR ${VTK_BUILD_PATH}
RUN wget https://gitlab.kitware.com/vtk/vtk/-/archive/v${VTK_VERSION}/vtk-v${VTK_VERSION}.tar.gz && \
    tar -xzf vtk-v${VTK_VERSION}.tar.gz && \
    rm vtk-v${VTK_VERSION}.tar.gz && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DBUILD_TESTING=OFF \
          -DBUILD_DOCUMENTATION=OFF \
          -DBUILD_EXAMPLES=OFF \
          -DVTK_DATA_EXCLUDE_FROM_ALL:BOOL=ON \
          -DVTK_Group_Qt:BOOL=OFF \
          -DVTK_DEBUG_LEAKS:BOOL=OFF \
          -DVTK_WRAP_PYTHON=ON \
          -DVTK_PYTHON_VERSION=${VTK_PYTHON_VERSION} \
          -DVTK_ENABLE_VTKPYTHON:BOOL=OFF \
          -DVTK_USE_X=OFF \
          -DVTK_USE_COCOA=FALSE \
          -DBUILD_SHARED_LIBS=ON \
          -DVTK_OPENGL_HAS_EGL=False \
          -DVTK_OPENGL_HAS_OSMESA=ON \
          -DVTK_DEFAULT_RENDER_WINDOW_OFFSCREEN=ON \
          -DOSMESA_INCLUDE_DIR=${MESA_INSTALL_PATH}/include/ \
          -DOSMESA_LIBRARY=${MESA_INSTALL_PATH}/lib/libOSMesa.so \
          -DCMAKE_INSTALL_PREFIX=${VTK_INSTALL_PATH} \
          -DPYTHON_EXECUTABLE=/usr/bin/python${VTK_PYTHON_VERSION} \
          -DPYTHON_INCLUDE_DIR=/usr/include/python${VTK_PYTHON_VERSION} \
          -DPYTHON_LIBRARY=/usr/lib/python${VTK_PYTHON_VERSION}/config-${VTK_PYTHON_VERSION}m-x86_64-linux-gnu/libpython${VTK_PYTHON_VERSION}.so \
          vtk-v${VTK_VERSION}/ && \
    make -j $(nproc --all) && \
    make install

ENV VTK_DIR=${VTK_INSTALL_PATH}
ENV VTKPYTHONPATH=${VTK_DIR}/lib/python${VTK_PYTHON_VERSION}/site-packages:${VTK_DIR}/lib

ENV LD_LIBRARY_PATH=${VTK_DIR}/lib:${MESA_INSTALL_PATH}/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=${PYTHONPATH}:${VTKPYTHONPATH}

WORKDIR ${VTK_INSTALL_PATH}/lib/python${VTK_PYTHON_VERSION}/site-packages
ADD setup.py setup.py
RUN python${VTK_PYTHON_VERSION} setup.py bdist_wheel && \
    mv dist/vtk-${VTK_VERSION}-py${VTK_PYTHON_VERSION%%.*}-none-any.whl ${VTK_INSTALL_PATH}/vtk-${VTK_VERSION}-py${VTK_PYTHON_VERSION%%.*}-none-any.whl && \
    rm -rf build dist setup.py vtk.egg-info __pycache__

FROM vtk-base as vtk-install

ARG MESA_INSTALL_PATH
ARG MESA_VERSION
ARG VTK_INSTALL_PATH
ARG VTK_PYTHON_VERSION
ARG VTK_VERSION

ENV MESA_INSTALL_PATH=${MESA_INSTALL_PATH:-/mesa}
ENV MESA_VERSION=${MESA_VERSION:-19.0.8}
ENV VTK_INSTALL_PATH=${VTK_INSTALL_PATH:-/vtk}
ENV VTK_PYTHON_VERSION=${VTK_PYTHON_VERSION:-3.7}
ENV VTK_VERSION=${VTK_VERSION:-8.2.0}

ENV VTK_DIR=${VTK_INSTALL_PATH}
ENV VTKPYTHONPATH=${VTK_DIR}/lib/python${VTK_PYTHON_VERSION}/site-packages:${VTK_DIR}/lib

ENV LD_LIBRARY_PATH=${VTK_DIR}/lib:${MESA_INSTALL_PATH}/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=${PYTHONPATH}:${VTKPYTHONPATH}

WORKDIR /
RUN mkdir -p ${MESA_INSTALL_PATH}
COPY --from=vtk ${MESA_INSTALL_PATH} ${MESA_INSTALL_PATH}
COPY --from=vtk ${VTK_INSTALL_PATH} ${VTK_INSTALL_PATH}
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
        llvm-7-runtime \
        libopenmpi-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${VTK_INSTALL_PATH}
RUN python${VTK_PYTHON_VERSION} -m pip install vtk-${VTK_VERSION}-py${VTK_PYTHON_VERSION%%.*}-none-any.whl

WORKDIR /
RUN touch VERSION && \
    echo "Mesa => ${MESA_VERSION}\n" >> VERSION && \
    echo "VTK => ${VTK_VERSION}\n" >> VERSION

ADD test.py vtk_install_test.py
RUN python3 vtk_install_test.py && rm vtk_install_test.py
