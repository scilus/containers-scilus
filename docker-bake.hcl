# docker-bake.hcl

variable "base-scilus-image" {
    default = "nvidia/cuda:9.2-runtime-ubuntu18.04"
}

variable "base-build-image" {
    default = "ubuntu:18.04"
}

variable "base-python-image" {
    default = "python:3.7.15-buster"
}

variable "ants-version" {
    default = "2.3.4"
}
variable "cmake-version" {
    default = "3.16.3"
}

variable "dmriqcpy-version" {
    default = "0.1.6"
}

variable "fsl-version" {
    default = "6.0.5.2"
}

variable "mrtrix-version" {
    default = "3.0_RC3"
}

variable "scilpy-version" {
    default = "master"
}

variable "mesa-version" {
    default = "19.0.8"
}

variable "vtk-version" {
    default = "8.2.0"
}

variable "python-version" {
    default = "3.7"
}

variable "itk-num-threads" {
    default = "8"
}

variable "blas-num-threads" {
    default = "1"
}

group "scilus" {
    targets = ["scilus"]
}

group "scilus-base" {
    targets = ["scilus-base"]
}

group "scilpy" {
    targets = ["scilpy"]
}

group "dmriqcpy" {
    targets = ["dmriqcpy"]
}

target "scilus" {
    dockerfile = "scilus.Dockerfile"
    context = "./containers/scilus.context/"
    target = "scilus"
    contexts = {
        scilus-base = "target:scilus-scilpy"
    }
    args = {
        ITK_NUM_THREADS = "${itk-num-threads}"
    }
    output = ["type=image"]
}

target "scilus-scilpy" {
    inherits = ["scilpy"]
    contexts = {
        scilpy-base = "target:scilus-base"
    }
    output = ["type=cacheonly"]
}

target "scilpy" {
    dockerfile = "scilpy.Dockerfile"
    context = "./containers"
    contexts = {
        scilpy-base = "docker-image://${base-python-image}"
    }
    args = {
        SCILPY_VERSION = "${scilpy-version}"
        BLAS_NUM_THREADS = "${blas-num-threads}"
    }
    tags = ["docker.io/avcaron/scilpy:dev"]
    cache-from = ["type=registry,ref=avcaron/scilpy"]
    cache-to = ["type=registry,ref=avcaron/scilpy"]
    output = ["type=image"]
}

target "scilus-base" {
    inherits = ["dmriqcpy"]
    contexts = {
        dmriqcpy-base = "target:scilus-vtk"
    }
    tags = ["docker.io/avcaron/scilus-base:dev"]
    cache-from = ["type=registry,ref=avcaron/scilus-base"]
    cache-to = ["type=registry,ref=avcaron/scilus-base"]
    pull = true
}

target "scilus-vtk" {
    inherits = ["vtk"]
    contexts = {
        vtk-base = "target:scilus-python"
    }
    output = ["type=cacheonly"]
}

target "scilus-python" {
    dockerfile = "scilus-python.Dockerfile"
    context = "./containers"
    contexts = {
        python-base = "target:fsl"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
    }
    output = ["type=cacheonly"]
}

target "dmriqcpy" {
    dockerfile = "dmriqcpy.Dockerfile"
    context = "./containers"
    contexts = {
        dmriqcpy-base = "target:vtk"
    }
    args = {
        DMRIQCPY_VERSION = "${dmriqcpy-version}"
        PYTHON_VERSION = "${python-version}"
        VTK_VERSION = "${vtk-version}"
    }
    tags = ["docker.io/avcaron/dmriqcpy:dev"]
    cache-from = ["type=registry,ref=avcaron/dmriqcpy"]
    cache-to = ["type=registry,ref=avcaron/dmriqcpy"]
    output = ["type=image"]
}

target "fsl" {
    dockerfile = "fsl.Dockerfile"
    context = "./containers"
    target = "fsl-install"
    contexts = {
        fsl-base = "target:mrtrix"
        fsl-builder = "docker-image://${base-build-image}"
    }
    args = {
        FSL_VERSION = "${fsl-version}"
    }
    output = ["type=cacheonly"]
}

target "mrtrix" {
    dockerfile = "mrtrix.Dockerfile"
    context = "./containers"
    target = "mrtrix-install"
    contexts = {
        mrtrix-base = "target:ants"
        mrtrix-builder = "docker-image://${base-build-image}"
    }
    args = {
        MRTRIX_VERSION = "${mrtrix-version}"
    }
    output = ["type=cacheonly"]
}

target "ants" {
    dockerfile = "ants.Dockerfile"
    context = "./containers"
    target = "ants-install"
    contexts = {
        ants-base = "docker-image://${base-scilus-image}"
        ants-builder = "target:cmake"
    }
    args = {
        ANTS_VERSION = "${ants-version}"
    }
    output = ["type=cacheonly"]
}

target "vtk" {
    dockerfile = "vtk-omesa.Dockerfile"
    context = "./containers/vtk-omesa.context/"
    target = "vtk-install"
    contexts = {
        vtk-base = "docker-image://${base-python-image}"
        vtk-builder = "target:cmake"
    }
    args = {
        MESA_VERSION = "${mesa-version}"
        VTK_PYTHON_VERSION = "${python-version}"
        VTK_VERSION = "${vtk-version}"
    }
    output = ["type=cacheonly"]
}

target "cmake" {
    dockerfile = "cmake.Dockerfile"
    context = "./containers"
    target = "cmake"
    contexts = {
        cmake-builder = "docker-image://${base-build-image}"
    }
    args = {
        CMAKE_VERSION = "${cmake-version}"
    }
    output = ["type=cacheonly"]
}
