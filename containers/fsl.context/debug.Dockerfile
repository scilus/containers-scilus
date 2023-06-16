# syntax=docker.io/docker/dockerfile:1.5.0

FROM base-image as debug

WORKDIR /
COPY --link fslinstaller.py /fslinstaller.py
COPY --link fsl_conda_env.yml /fsl_conda_env.yml

WORKDIR /
RUN ls -lha && cd kaka
