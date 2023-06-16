# syntax=docker.io/docker/dockerfile:1.5.0

FROM base-image as debug

ADD --link --chmod=755 https://github.com/MShekow/directory-checksum/releases/download/v1.4.1/directory-checksum_1.4.1_linux_amd64 /usr/local/bin/directory-checksum
COPY --chmod=666 fsl_conda_env.yml /fsl_build/fsl_conda_env.yml
COPY --chmod=666 fslinstaller.py /fsl_build/fslinstaller.py

WORKDIR /fsl_build
RUN ls -lha && directory-checksum --max-depth=1 .
