# syntax=docker.io/docker/dockerfile:1.5.0

FROM base-image as debug

WORKDIR /
COPY --chown=0:0 --link fslinstaller.py /fslinstaller.py
COPY --chown=0:0 --link fsl_conda_env.yml /fsl_conda_env.yml

WORKDIR /
RUN cat fslinstaller.py && cat fsl_conda_env.yml
