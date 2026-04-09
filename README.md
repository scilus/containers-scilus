
# Containers build system for the Scilus ecosystem

Build system for all docker containers of the `Scilus` ecosystem. The inventory
of containers is still being updated, here are the ones that are currently
available :

- [scilpy](https://github.com/scilus/scilpy)
- [dmriQCpy](https://github.com/scilus/dmriqcpy)
- [scilus](#scilus-container)
- [scilus-flows](#scilus-flows-container)

___

## Release cycle

> [!IMPORTANT]
> The release cycle of containers **is not automated !!!** Follow the procedure below carefully, to the letter, to ensure proper versioning of the containers.

Most containers follow the release cycles of their own dependencies - for example `scilpy` and `dmriQCpy` containers get pinned when their respective packages get new releases. They use their `version schemes` as is to tag the corresponding containers.

```
                  ┌──────────┐
                  │ Release  │───────────┐
                  └──────────┘           │
                       ▲                 │
                       │                 │
                       │                 ▼
    ┌────────┐    ┌──────────┐    ┌──────────────┐    ┌──────────────────────────┐
    │ scilpy │───▶│ .git tag │───▶│ docker build │───▶│ scilpy:<.git tag> image  │
    └────────┘    └──────────┘    └──────────────┘    └──────────────────────────┘
```

For the `scilus` container and its derivatives, its a bit different. Their content is too complex and interdependent to be tied to a single package release. However, crafting a relevant, humanly readable tag for them is still important. Concatenating all dependencies versions would be cumbersome, both in terms of maintenance and readability. Instead, we use a dual versioning scheme, involving both `date-based` and `semantic` branches.

### Semantic branch

The `semantic` branch is tied to the release cycle of the **main dependency** managed by the SCIL, `scilpy`. Aside those versions, a special `dev` tag is also maintained that tracks the latest changes brought by **any other dependencies** included in the container, since the last `scilpy` release. This way, new `scilpy` releases only need to be layered on top of the latest `dev` version to create a new stable release of `scilus`.

```
 ┌────────────┐       ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
 │ scilpy v1  │       │ dmriQCpy v+ │      │   ANTs v+   │      │ scilpy v2   │
 └────────────┘       └─────────────┘      └─────────────┘      └─────────────┘
       │                     │                    │                    │
       ▼                     ▼                    ▼                    ▼
┌──────────────┐       ┌────────────┐       ┌────────────┐       ┌────────────┐
│ scilus:v1    │──────▶│ scilus:dev │──────▶│ scilus:dev │──────▶│ scilus:v2  │
└──────────────┘       └────────────┘       └────────────┘       └────────────┘
```

### Date-based branch

The `date-based` branch is updated on a regular basis, each time the `dev` version gets bumped. It keeps track of rolling updates to dependencies that do not warrant a new `scilpy` release, so that users can introspect their container when hitting problems or needing specific informations about the environment. The date-based tag uses the format `YYYYMMDD` (for example, `20240315` for March 15th, 2024).

```
           ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
           │ dmriQCpy v+     │       │   ANTs v+       │       │ dmriQCpy v+     │
           └─────────────────┘       └─────────────────┘       └─────────────────┘
                    │                         │                         │
                    ▼                         ▼                         ▼
           ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
    ──────▶│ scilus:dev      │──────▶│ scilus:dev      │──────▶│ scilus:dev      │──────▶
           └─────────────────┘       └─────────────────┘       └─────────────────┘
                    │                         │                         │
                    ▼                         ▼                         ▼
           ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
           │ scilus:20240301 │       │ scilus:20240401 │       │ scilus:20240501 │
           └─────────────────┘       └─────────────────┘       └─────────────────┘
```

### Version ledger

Since neither versioning branch reflects the dependencies versions, a `VERSIONS` file acts as a ledger for it. It is located at the root of each container, and lists the versions of
all major dependencies installed in the it. Each versioning line is crafted using the following syntax :

```
<dependency name> => <version string>
```

## First setup

Before running any `docker` commands, ensure the following docker extensions are
available on your system at the prescribed versions :

- `buildx` : [v0.11](https://github.com/docker/buildx/releases/tag/v0.11.0) or greater
  - To get your current version, run : `docker buildx version`
  - Follow instructions [from docker](https://github.com/docker/buildx#manual-download)
    to update following your operation system
- `buildkit` : [v0.11.6](https://hub.docker.com/layers/moby/buildkit/v0.11.6/images/sha256-da98722273918d50e0aceb5ad414398e8bfe571dbdbc8ada80ae4839b3e0058e?context=explore) or greater
  - To get your current version, run : `docker buildx inspect --bootstrap`
  - To update the version, [create a new builder instance](#create-the-builder-instance) for buildx using the version you want as the `moby/buildkit` image tag

### Create the builder instance

The build system uses the `docker-container` backend instead of the default `docker`
build. Create your builder and make it the default one with the following command :

```
docker buildx create \
    --use \
    --driver docker-container \
    --driver-opt "image=moby/buildkit:v0.11.6"
```

The builder instance will appear as a container in the docker interface under a
randomly generated name (you can check it using `docker ps`) and should not be
deleted. If it is, local cache will be erased; a new builder can be created by
re-running the command above.

#### Using a remote builder instance via ssh

With **buildx**, it's no longer necessary to run the actual image build locally. If, for example
you have access to a remote server with large resources, you can create a builder instance on it
and link it locally for use by **docker**.

##### On the remote server

First, ensure both [docker](https://docs.docker.com/engine/install/) and
[buildx](https://github.com/docker/buildx) are installed on the remote server.
If not, use the command below :

```bash
curl -fsSL https://get.docker.com | sh
```

> [!IMPORTANT]
> Your user on the remote server needs to be part of the `docker` group to be able to use `buildx` without `sudo`.
> It is mandatory since most **ssh** setups don't allow passwordless `sudo` commands. Run :
>
> ```bash
> sudo usermod -aG docker $USER
> newgrp docker
> ```

Once done, test the installation by running `docker buildx version` on the remote server.

>[!WARNING]
> If the `docker buildx version` command returns an error, there was a problem with the installation.
> Get in contact with us, via [Github issues](https://github.com/scilus/containers-scilus/issues), to
> get help with it.

##### On your local machine

Log off the remote server and back on your local machine you want to connect from. Create a new
**ssh key pair** if you don't have one already :

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_container_scilus_builder -C "scilus builder"
```

Then, copy that key to the remote server, replacing `<remote_user>` and `<remote_host>` with the
appropriate values for your setup (and the `-i` argument with the path to your key if you used
a different one) :

```bash
ssh-copy-id -i ~/.ssh/id_container_scilus_builder.pub <remote_user>@<remote_host>
```

> [!IMPORTANT]
> If using a custom key, ensure that the `~/.ssh/config` file is properly configured to use it,
> and that it is loaded correctly by the `ssh-agent`. One way is adding the following lines to your
> `~/.ssh/config` file :
>
> ```bash
> Host <remote_host>
>     User <remote_user>
>     IdentityFile ~/.ssh/id_container_scilus_builder
> ```

Finally, create a new builder instance with the following command, replacing `<remote_user>` and
`<remote_host>` with the appropriate values for your setup :

```bash
docker buildx create \
    --use \
    --name containers-scilus-builder \
    --driver docker-container \
    --driver-opt network=host \
    --platform linux/amd64 \
    ssh://<remote_user>@<remote_host>
```

## Building containers

To build an image, launch the following command at the root directory of the
repository :

```bash
docker buildx bake \
    -f versioning.hcl \
    -f docker-bake.hcl \
    <target>
```

with a target in : `dmriqcpy`, `scilpy`, `scilus`, `scilus-flows`. Follow
[this link](docker-bake.md) for more information on the build system.

To prevent some parts of the build system to execute - conserve remote cache
access and accelerate builds - the build tree was fragmented into 3 chunks :
`dependencies`, `scilus` and `flows`. This procedure uses 3 environment variables :

- `DEPS_TAG` : fix the dependencies image tag used. When building `scilus-deps`,
  this outputs an image named : `scilus/scilus-deps:<DEPS_TAG>` into the local
  docker repository. When building `scilus`, the base image is overridden to
  point to `scilus/scilus-deps:<DEPS_TAG>` and building of dependencies is skipped.

- `SCILUS_TAG` : fix the scilus image tag used. When building `scilus`,
  this outputs an image named : `scilus/scilus:<SCILUS_TAG>` into the local
  docker repository. When building `scilus-flows`, the base image is overridden to
  point to `scilus/scilus:<SCILUS_TAG>` and building of dependencies and scilus are
  skipped.

- `FLOWS_TAG` : fix the scilus-flows image tag used. When building `scilus-flows`,
  this outputs an image named : `scilus/scilus-flows:<FLOWS_TAG>` into the local
  docker repository.

**When using this procedure, images must be pushed to a remote repository before
they can be used in subsequent builds, since buildx cannot fetch images from the
local docker repository. See the following example :**

This examples builds each chunk of the `scilus` image stack separately. Each intermediary
`scilus` result is pushed to dockerhub in order to be used in the subsequent build
steps :

```bash
# Build dependencies and publish the image as scilus/scilus-deps:dev0
DEPS_TAG=dev0 docker buildx bake -f versioning.hcl -f docker-bake.hcl scilus-deps
docker push scilus/scilus-deps:dev0

# Build scilus from scilus/scilus-deps:dev0 and publish the image as scilus/scilus:dev1
DEPS_TAG=dev0 SCILUS_TAG=dev1 docker buildx bake -f versioning.hcl -f docker-bake.hcl scilus
docker push scilus/scilus:dev1

# Build scilus-flows from scilus/scilus:dev1 and publish the image as scilus/scilus-flows:dev2
SCILUS_TAG=dev1 FLOWS_TAG=dev2 docker buildx bake -f versioning.hcl -f docker-bake.hcl scilus-flows
docker push scilus/scilus-flows:dev2
```

For example, building `scilus` with `DEPS_TAG=dev0` and `SCILUS_TAG=dev1` will create an imaged named `scilus/scilus:dev1`. To use `scilus/scilus:dev1` as a base for `scilus-flows`, it must be pushed to dockerhub first (`docker push scilus/scilus:dev1`). Then a build of `scilus-flows` using `SCILUS_TAG=dev1` and `FLOWS_TAG=dev2` will results in an image named `scilus/scilus-flows:dev2` based on `scilus/scilus:dev1`. Else, the image will be based on another version of `scilus/scilus:dev1` if available on dockerhub, or the build will crash if not.**
___

## Containers update

Container update is done via `Github actions` on the main repositories. `Docker`
images are available on [Dockerhub](https://hub.docker.com/u/scilus).
`Singularity` images light enough to be stored on `Github` can be found in
repositories releases. Follow [this link](container-update.md) for more
information on the update system.
___

## Versioning containers

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

```bash
python<py_version> -m pip list
```

___

## Main containers in the build system

### `scilus` container

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

### `scilus-flows` container

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

## Singularity / Apptainer

The image for Singularity / Apptainer can be built using `singularity_scilus.def` with the
command:

`sudo apptainer build scilus_${SCILPY_VERSION}.img singularity_scilus.def`.

The image is built from the Docker stored on dockerhub.

It can be used to run any SCILUS flows with the option
`-with-singularity scilus_${SCILPY_VERSION}.img` of Nextflow.

If you use this image, please cite:

```
Kurtzer GM, Sochat V, Bauer MW (2017)
Singularity: Scientific containers for mobility of compute.
PLoS ONE 12(5): e0177459. https://doi.org/10.1371/journal.pone.0177459
```

___

## Building the `scilus-deps` container

Changing some dependencies can lead to a full rebuild of the `scilus` image
stack, which can be too intense for some computers. Some dependencies such as
`FSL` or `ANTs` are even too long or take too much resources to build on default
`Github` workers.

To build `scilus-deps`, we recommend a computer with at least `8 CPU threads`,
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
