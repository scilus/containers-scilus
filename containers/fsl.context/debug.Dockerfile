# syntax=docker.io/docker/dockerfile:1.5.0

FROM base-image as debug

WORKDIR /
COPY --chown=0:0 --chmod=755 --link fslinstaller.py /fslinstaller.py
COPY --chown=0:0 --chmod=555 --link fsl_conda_env.yml /fsl_conda_env.yml

WORKDIR /
RUN cat fslinstaller.py && cat fsl_conda_env.yml
