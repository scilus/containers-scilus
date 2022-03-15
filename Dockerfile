FROM scilus/base-scilus:2.0.0

ENV ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8
ENV OPENBLAS_NUM_THREADS=1
ENV MATPLOTLIBRC="/usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/"
ENV LC_ALL=C

ADD human-data_master_1d3abfb.tar.bz2 /human-data

WORKDIR /
ENV SCILPY_VERSION="1.3.0-rc2"
RUN wget https://github.com/scilus/scilpy/archive/${SCILPY_VERSION}.zip &&\
    unzip ${SCILPY_VERSION}.zip &&\
    mv scilpy-${SCILPY_VERSION} scilpy

WORKDIR /scilpy
RUN pip3 install bz2file==0.98 &&\
    pip3 install coloredlogs==10.0 &&\
    pip3 install cycler==0.10.0 &&\
    pip3 install Cython==0.29.28 &&\
    pip3 install dipy==1.3.0 &&\
    pip3 install fury==0.7.1 &&\
    pip3 install future==0.17.1 &&\
    pip3 install h5py==2.10.0 &&\
    pip3 install kiwisolver==1.0.1 &&\
    pip3 install matplotlib==2.2.5 &&\
    pip3 install nibabel==3.0.2 &&\
    pip3 install nilearn==0.6.2 &&\
    pip3 install numpy==1.21.5 &&\
    pip3 install Pillow==9.0.1 &&\
    pip3 install bids-validator==1.6.0 &&\
    pip3 install pybids==0.10.2 &&\
    pip3 install pyparsing==2.2.2 &&\
    pip3 install python-dateutil==2.7.5 &&\
    pip3 install pytz==2018.4 &&\
    pip3 install scikit-learn==0.22.2.post1 &&\
    pip3 install scipy==1.4.1 &&\
    pip3 install setuptools==46.1.3 &&\
    pip3 install six==1.15.0 &&\
    pip3 install trimeshpy==0.0.2 &&\
    pip3 install coloredlogs==10.0 &&\
    pip3 install nilearn==0.6.2 &&\
    pip3 install pytest==5.3.5 &&\
    pip3 install pytest_console_scripts==0.2.0 &&\
    pip3 install gdown==4.3.1 &&\
    pip3 install requests==2.23.0 &&\
    pip3 install openpyxl==2.6.4 &&\
    pip3 install bctpy==0.5.2 &&\
    pip3 install statsmodels==0.11.1 &&\
    pip3 install dmri-commit==1.4.5 &&\
    pip3 install cvxpy==1.1.18

ENV DMRIQCPY_VERSION="0.1.5-rc12"

WORKDIR /
RUN pip3 install git+https://github.com/scilus/scilpy.git@${SCILPY_VERSION}
RUN pip3 install git+https://github.com/scilus/dmriqcpy.git@${DMRIQCPY_VERSION}
RUN cp -r /scilpy/data /usr/local/lib/python3.7/dist-packages/

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/matplotlibrc
RUN pip3 uninstall -y vtk
