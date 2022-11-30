
Containers build system for the Scilus ecosystem
================================================

Build system for all docker containers of the `Scilus` ecosystem. The inventory 
of containers is still being updated, here are the ones that are currently 
available :

- [scilpy](https://github.com/scilus/scilpy)
- [dmriQCpy](https://github.com/scilus/dmriqcpy)
- [scilus](#scilus-container)
- [scilus-flows](#scilus-flows-container)

___

Containers update
-----------------

Container update is done via `Github actions` on the main repositories. `Docker` 
images are available on [Dockerhub](https://hub.docker.com/u/scilus). 
`Singularity` images light enough to be stored on `Github` can be found in 
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
    -f versioning/<target>-versioning.hcl \
    -f docker-bake.hcl \
    <target>
```

with a target in : `dmriqcpy`, `scilpy`, `scilus`, `scilus-flows`. Follow 
this [link](docker-bake.md) for more information on the build system.

___

`scilus` container
---------------------------

The `scilus` containers is packaged with `scilpy` and `dmriQCpy`, as well as 
other external dependencies shared between scilus flows. Here is the list of 
dependencies installed in the container :

- [scilpy](https://github.com/scilus/scilpy)
- [dmriQCpy](https://github.com/scilus/dmriqcpy)
- [ANTs](https://github.com/ANTsX/ANTs)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
- [Mrtrix](https://www.mrtrix.org/)
- [Python](https://www.python.org/)
- [VTK](https://vtk.org/)
- [MESA](https://www.mesa3d.org/)
- [CUDA](https://developer.nvidia.com/cuda-toolkit)

See [versioning](#versioning-containers) for information on how to verify 
dependencies versions inside the `scilus` container.

___

`scilus-flows` container
---------------------------

The `scilus-flows` container comes pre-packaged with the popular `Nextflow` 
pipelines developed in the `Scilus` ecosystem. Here is the list of available 
pipelines in the container :

- [Tractoflow](https://github.com/scilus/tractoflow)
- [DMRIqc-flow](https://github.com/scilus/dmriqc_flow)
- [Extractor-flow](https://github.com/scilus/extractor_flow)
- [RBX-flow](https://github.com/scilus/rbx_flow)
- [Tractometry-flow](https://github.com/scilus/tractometry_flow)
- [Register-flow](https://github.com/scilus/register_flow)
- [Disconets-flow](https://github.com/scilus/disconets_flow)
- [Freewater-flow](https://github.com/scilus/freewater_flow)
- [NODDI-flow](https://github.com/scilus/noddi_flow)
- [BST-flow](https://github.com/scilus/bst_flow)

They can either be called using their `install location` (in 
`/scilus_flows/<pipeline name>/main.nf`) or via their predefined `alias` (the 
name of the pipeline listed above, with dashes, in lowercase). For example,

`docker run <scilus-flows image> tractometry-flow <args>`

is equivalent to 

`docker run <scilus-flows image> nextflow run /scilus_flows/tractometry_flow/main.nf <args>`

___

Versioning containers
---------------------

Containers in the `Scilus` ecosystem are thouroughly versioned to ensure 
compatibility and for validation purposes. We do not version for all 
sub-dependencies that are included in the container, nor do we enforce the 
version of dependencies acquired via means such as `apt-get`.

Versions of the dependencies of interest are specified in a file at the root 
of the image named `VERSION`. Other dependencies may have been installed in 
the image in `apt-get` or `pip`, which can both be inspected if needs be. 
For `python` dependencies, please note that the interpreter to target is 
located in `/usr/bin`. To list packages installed in the image, assuming 
the python version inside it being `<py_version>`, execute the 
command :

```
python<py_version> -m pip list
```

___

Building the `scilus-base` container
------------------------------------

Changing some dependencies can lead to a full rebuild of the `scilus` image 
stack, which can be too intense for some computers. Some dependencies such as 
`FSL` or `ANTs` are even too long or take too much resources to build on default 
`Github` workers.

To build `scilus-base`, we recommend a computer with at least `8 CPU threads`, 
`32Gb of RAM`, as well as an Internet connection with a `large outgoing bandwidth` 
for cache uploading to `dockerhub`. Once the cache is online, subsequent builds 
will skip those steps, making it possible to build higher level images on 
systems with fewer computing resources.

Note that for now, nothing is done to limit resource usage by the build system, 
and thus, it is possible for the build sequence to fill up all available RAM or 
occupy 100% of CPU cores. This could be achieved by using the 
[Kubernetes](https://docs.docker.com/build/building/drivers/kubernetes/) buildx 
builder instance. Switching to it could be envisioned when it gets fully 
documented and its deployment on linux machine becomes easy enough (right now, 
it is a walk in the park on Windows using Docker-Desktop and a real hassle on 
Linux OSes).

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
