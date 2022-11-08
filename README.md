
Containers build system for the Scilus ecosystem
================================================

Build system for all docker containers of the Scilus ecosystem. The inventory 
of containers is still being updated, here are the ones that are currently 
available :

- [Scilpy](https://github.com/scilus/scilpy)
- [dmriQCpy](https://github.com/scilus/dmriqcpy)
- Scilus : container to use with all Scilus flows

___

Containers update
-----------------

Container update is done via Github actions on the main repositories. Docker 
images are available on [Dockerhub](https://hub.docker.com/u/scilus). 
Singularity images light enough to be stored on Github can be found in 
repositories releases. Follow this [link](container-update.md) for more 
information on the update system.

___

Building containers
-------------------

On the first use of the build system on a specific envrionment, run the 
following command :

`docker buildx create --use`

It will create a new builder instance (an image and a container will be added to 
your docker local repository) that enables caching features used by the system.

To build an image, launch the following command at the root directory of the 
repository :

```
docker buildx bake \
    -f docker-bake.hcl \
    -f versioning/<target>-versioning.hcl \
    <target>
```

with a target in : `dmriqcpy`, `scilpy`, `scilus`. Follow this 
[link](docker-bake.md) for more information on the build system.

To build images with nextflow in them, use the following command :

```
docker buildx bake \
    -f docker-bake.hcl \
    -f versioning/nextflow-versioning.hcl \
    -f versioning/<target>-versioning.hcl \
    <target>-nextflow
```

Only some target are available to be built with Nextflow, here is the list :

- `scilus`

To limit the number of cpus used by each build step, prepend the command by 
`BUILD_N_THREADS=<number of threads>`. When building the full `scilus` image 
stack, there will be at one moment at least 3 big libraries building 
simultaneously. Limiting the number of cpus for each of them to the third 
available can prevent the build machine from freezing. However, nothing can be 
done to limit the usage in RAM of the current builder instance. To do so, the 
[Kubernetes](https://docs.docker.com/build/building/drivers/kubernetes/) builder 
instance must be used (easy on Windows using Docker-Desktop, harder to install 
on Linux OSes).

___

Singularity
-----------

The image for Singularity can be built using `singularity_scilus.def` with the 
command:

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

___
