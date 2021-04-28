[![GitHub release (latest by date)](https://img.shields.io/github/v/release/scilus/containers-scilus)](https://github.com/scilus/containers-scilus/releases)
[![Build Status](https://travis-ci.org/scilus/containers-scilus.svg?branch=master)](https://travis-ci.org/scilus/containers-scilus)

Containers related files for SCILUS flows
=========================================

Containers update
-----------------
When updating `Scilpy`, you will need to modify the SHA of the file, as well as
the `SCILPY_VERSION` variable in `Dockerfile`.

Docker
------
To build the docker use the following command:

`sudo docker build -t docker_scilus .`

Singularity
-----------
The image for Singularity can be built using `singularity_scilus.def` with the command:
`sudo singularity build scilus_${SCILPY_VERSION}.img singularity_scilus.def`.

Singularity container is built from the Docker stored on dockerhub.

It can be used to run any SCILUS flows with the option
`-with-singularity scilus_${SCILPY_VERSION}.img` of Nextflow.

If you use this singularity, please cite:

```
Kurtzer GM, Sochat V, Bauer MW (2017)
Singularity: Scientific containers for mobility of compute.
PLoS ONE 12(5): e0177459. https://doi.org/10.1371/journal.pone.0177459
```
