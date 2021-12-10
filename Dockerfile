FROM scilus/base-scilus:dev

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8
ENV OPENBLAS_NUM_THREADS=1
ENV MATPLOTLIBRC="/usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/"
ENV LC_ALL=C

ADD human-data_master_1d3abfb.tar.bz2 /human-data

WORKDIR /
RUN SCILPY_VERSION="1.1.0" && wget https://github.com/scilus/scilpy/archive/${SCILPY_VERSION}.zip &&\
    unzip ${SCILPY_VERSION}.zip &&\
    mv scilpy-${SCILPY_VERSION} scilpy

WORKDIR /scilpy
RUN pip3 install bz2file==0.98 &&\
    pip3 install coloredlogs==10.0 &&\
    pip3 install cycler==0.10.0 &&\
    pip3 install Cython==0.29.12 &&\
    pip3 install dipy==1.3.0 &&\
    pip3 install fury==0.6.0 &&\
    pip3 install future==0.17.1 &&\
    pip3 install h5py==2.10.0 &&\
    pip3 install kiwisolver==1.0.1 &&\
    pip3 install matplotlib==2.2.2 &&\
    pip3 install nibabel==3.0.1 &&\
    pip3 install nilearn==0.6.1 &&\
    pip3 install numpy==1.18.4 &&\
    pip3 install Pillow==7.1.2 &&\
    pip3 install bids-validator==1.6.0 &&\
    pip3 install pybids==0.10.2 &&\
    pip3 install pyparsing==2.2.0 &&\
    pip3 install python-dateutil==2.7.2 &&\
    pip3 install pytz==2018.4 &&\
    pip3 install scikit-learn==0.22.1 &&\
    pip3 install scipy==1.4.1 &&\
    pip3 install setuptools==46.1.3 &&\
    pip3 install six==1.15.0 &&\
    pip3 install trimeshpy==0.0.2 &&\
    pip3 install coloredlogs==10.0 &&\
    pip3 install nilearn==0.6.1 &&\
    pip3 install pytest==5.3.5 &&\
    pip3 install pytest_console_scripts==0.2.0 &&\
    pip3 install googledrivedownloader==0.4 &&\
    pip3 install requests==2.23.0 &&\
    pip3 install openpyxl==2.6.4 &&\
    pip3 install bctpy==0.5.2 &&\
    pip3 install statsmodels==0.11.1 &&\
    pip3 install dmri-commit==1.4.5 &&\
    pip3 install cvxpy==1.0.31

RUN python3 setup.py build_ext --inplace &&\
    python3 setup.py install &&\
    python3 setup.py install_scripts &&\
    sed -i '41s/.*/backend : Agg/' /usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/matplotlibrc

WORKDIR /
RUN DMRIQCPY_VERSION="0.1.5-rc9" &&\
    wget https://github.com/scilus/dmriqcpy/archive/refs/tags/${DMRIQCPY_VERSION}.zip &&\
    unzip ${DMRIQCPY_VERSION}.zip &&\
    mv dmriqcpy-${DMRIQCPY_VERSION} dmriqcpy

WORKDIR /dmriqcpy
RUN pip3 install -e .
