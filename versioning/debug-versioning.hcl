# scilus-versioning.hcl

base-install-image="nvidia/cuda:11.7.1-runtime-ubuntu22.04"
base-build-image="ubuntu:jammy-20230301"

ants-version="2.4.3"
cmake-version="3.16.3"
dmriqcpy-version="0.1.7"
fsl-version="6.0.6"
mrtrix-version="3.0.4"  
scilpy-version="1.5.0"
mesa-version="22.0.5"
vtk-version="9.2.6"
python-version="3.10"

dmriqcpy-test-base="scilus-base"
scilpy-test-base="scilus-scilpy"
vtk-test-base="scilus-vtk"
