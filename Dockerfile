FROM scilus/base-scilus:dev

ENV MATPLOTLIBRC="/usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/"
ENV LC_ALL=C

ADD human-data_master_1d3abfb.tar.bz2 /human-data

RUN apt-get -y install fonts-freefont-ttf

WORKDIR /
ENV SCILPY_VERSION="1.2.2"
RUN wget https://github.com/scilus/scilpy/archive/${SCILPY_VERSION}.zip
RUN unzip ${SCILPY_VERSION}.zip
RUN mv scilpy-${SCILPY_VERSION} scilpy

WORKDIR /scilpy
RUN pip3 install bz2file==0.98
RUN pip3 install coloredlogs==10.0
RUN pip3 install cycler==0.10.0
RUN pip3 install Cython==0.29.12
RUN pip3 install dipy==1.3.0
RUN pip3 install fury==0.7.0
RUN pip3 install future==0.17.1
RUN pip3 install h5py==2.10.0
RUN pip3 install kiwisolver==1.0.1
RUN pip3 install matplotlib==2.2.2
RUN pip3 install nibabel==3.0.1
RUN pip3 install nilearn==0.6.1
RUN pip3 install numpy==1.20.3
RUN pip3 install Pillow==8.2.0
RUN pip3 install bids-validator==1.6.0
RUN pip3 install pybids==0.10.2
RUN pip3 install pyparsing==2.2.0
RUN pip3 install python-dateutil==2.7.3
RUN pip3 install pytz==2018.4
RUN pip3 install scikit-learn==0.22.1
RUN pip3 install scipy==1.4.1
RUN pip3 install setuptools==46.1.3
RUN pip3 install six==1.15.0
RUN pip3 install vtk==9.0.1
RUN pip3 install trimeshpy==0.0.2
RUN pip3 install coloredlogs==10.0
RUN pip3 install nilearn==0.6.1
RUN pip3 install pytest==5.3.5
RUN pip3 install pytest_console_scripts==0.2.0
RUN pip3 install googledrivedownloader==0.4
RUN pip3 install requests==2.23.0
RUN pip3 install openpyxl==2.6.4
RUN pip3 install bctpy==0.5.2
RUN pip3 install statsmodels==0.11.1
RUN pip3 install dmri-commit==1.4.5
RUN pip3 install cvxpy==1.1.13

RUN python3 setup.py build_ext --inplace
RUN python3 setup.py install
RUN python3 setup.py install_scripts

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python3.7/dist-packages/matplotlib/mpl-data/matplotlibrc

WORKDIR /
ENV DMRIQCPY_VERSION="0.1.5-rc9"
RUN wget https://github.com/scilus/dmriqcpy/archive/refs/tags/${DMRIQCPY_VERSION}.zip
RUN unzip ${DMRIQCPY_VERSION}.zip
RUN mv dmriqcpy-${DMRIQCPY_VERSION} dmriqcpy

WORKDIR /dmriqcpy
RUN pip3 install jinja2==3.0.3
RUN pip3 install plotly==5.3.1
RUN pip3 install MarkupSafe==2.0.1
RUN pip3 install tenacity==8.0.1

RUN pip3 install -e .
