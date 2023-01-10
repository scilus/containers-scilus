# nextflow-versioning.hcl

base-scilus-image="nvidia/cuda:11.7.1-runtime-ubuntu22.04"
base-build-image="ubuntu:22.04"

ants-version="2.4.3"
cmake-version="3.16.3"
dmriqcpy-version="0.1.6"
fsl-version="6.0.6"
mrtrix-version="3.0.4"
scilpy-version="1.4.0"
scilpy-requirements="requirements.1.4.0.frozen"
mesa-version="22.0.5"
vtk-version="9.2.0"
python-version="3.10"

dmriqcpy-test-base="scilus-base"
scilpy-test-base="scilus-scilpy"
vtk-test-base="scilus-vtk"

java-version="11"
nextflow-version="21.04.3"

tractoflow-version = "2.3.0"
dmriqc-flow-version = "0.1.0"
extractor-flow-version = "master"
rbx-flow-version = "1.1.0"
tractometry-flow-version = "1.0.0"
register-flow-version = "main"
disconets-flow-version = "0.1.0-rc1"
freewater-flow-version = "1.0.0"
noddi-flow-version = "1.0.0"
bst-flow-version = "1.0.0-rc1"
