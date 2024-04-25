# docker build for distributing a base fs 7.2.0 container

FROM freesurfer-base as freesurfer

ARG FREESURFER_VERSION
ENV FREESURFER_VERSION=${FREESURFER_VERSION:-7.4.1}

# shell settings
WORKDIR /

# install utils
RUN apt-get -y update
RUN apt-get -y install bc perl tar tcsh wget vim-common

RUN echo ${FREESURFER_VERSION}

# install fs
RUN wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer_ubuntu22-${FREESURFER_VERSION}_amd64.deb && \
    dpkg -i freesurfer_${FREESURFER_VERSION}_amd64.deb && \
    rm freesurfer_${FREESURFER_VERSION}_amd64.deb

# setup fs env
ENV OS Linux
ENV PATH /usr/local/freesurfer/bin:/usr/local/freesurfer/fsfast/bin:/usr/local/freesurfer/tktools:/usr/local/freesurfer/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV FREESURFER_HOME /usr/local/freesurfer
ENV FREESURFER /usr/local/freesurfer
ENV SUBJECTS_DIR /usr/local/freesurfer/subjects
ENV LOCAL_DIR /usr/local/freesurfer/local
ENV FSFAST_HOME /usr/local/freesurfer/fsfast
ENV FMRI_ANALYSIS_DIR /usr/local/freesurfer/fsfast
ENV FUNCTIONALS_DIR /usr/local/freesurfer/sessions

# set default fs options
ENV FS_OVERRIDE 0
ENV FIX_VERTEX_AREA ""
ENV FSF_OUTPUT_FORMAT nii.gz

# mni env requirements
ENV MINC_BIN_DIR /usr/local/freesurfer/mni/bin
ENV MINC_LIB_DIR /usr/local/freesurfer/mni/lib
ENV MNI_DIR /usr/local/freesurfer/mni
ENV MNI_DATAPATH /usr/local/freesurfer/mni/data
ENV MNI_PERL5LIB /usr/local/freesurfer/mni/share/perl5
ENV PERL5LIB /usr/local/freesurfer/mni/share/perl5

ENV FS_LICENSE='/license.txt'

RUN ( [ -f "VERSION" ] || touch VERSION ) && \
    echo "freesurfer => ${FREESURFER_VERSION}\n" >> VERSION