# docker-bake.hcl

# ==============================================================================
# BUILD VARIABLES
# ==============================================================================

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

variable "nextflow-version" {
    default = "21.04.3"
}

variable "java-version" {
    default = "11"
}

variable "itk-num-threads" {
    default = "8"
}

variable "blas-num-threads" {
    default = "1"
}

variable "scilpy-test-base" {
    default = "scilpy"
}

variable "dmriqcpy-test-base" {
    default = "dmriqcpy"
}

variable "vtk-base" {
    default = "docker-image://${base-python-image}"
}

# ==============================================================================
# DOCKER BUILDX BAKE TARGETS
# ==============================================================================

group "scilus-nextflow" {
    targets = ["scilus-nextflow", "scilus-test", "scilpy-test"]
}

group "scilus" {
    targets = ["scilus", "scilus-test", "scilpy-test"]
}

group "scilus-base" {
    targets = ["scilus-base", "dmriqcpy-test", "vtk-test"]
}

group "scilpy" {
    targets = ["scilpy", "scilpy-test", "vtk-test"]
}

group "dmriqcpy" {
    targets = ["dmriqcpy", "dmriqcpy-test", "vtk-test"]
}

# ==============================================================================
# TEST TARGETS
# ==============================================================================

target "dmriqcpy-test" {
    inherits = ["${dmriqcpy-test-base}"]
    target = "dmriqcpy-test"
    output = ["type=cacheonly"]
}

target "scilpy-test" {
    inherits = ["${scilpy-test-base}"]
    target = "scilpy-test"
    output = ["type=cacheonly"]
}

target "scilus-test" {
    inherits = ["scilus"]
    target = "scilus-test"
    output = ["type=cacheonly"]
}

target "vtk-test" {
    inherits = ["vtk"]
    target = "vtk-test"
    output = ["type=cacheonly"]
}

# ==============================================================================
# NEXTFLOW TARGETS
# ==============================================================================

target "scilus-nextflow" {
    inherits = ["nextflow"]
    contexts = {
        nextflow-base = "target:scilus"
    }
    tags = ["scilus:local+nextflow"]
    cache-from = ["type=registry,ref=avcaron/scilus"]
    output = ["type=docker"]
    pull = true
}

target "nextflow" {
    dockerfile = "nextflow.Dockerfile"
    context = "./containers"
    target = "nextflow"
    args = {
        NEXTFLOW_VERSION = "${nextflow-version}"
        JAVA_VERSION = "${java-version}"
    }
    output = ["type=cacheonly"]
}

# ==============================================================================
# BUILD TARGETS
# ==============================================================================

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
    tags = ["scilus:local"]
    cache-from = ["type=registry,ref=avcaron/scilus"]
    output = ["type=docker"]
    pull = true
}

target "scilus-scilpy" {
    inherits = ["scilpy"]
    contexts = {
        scilpy-base = "target:scilus-base"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
        SCILPY_VERSION = "${scilpy-version}"
        BLAS_NUM_THREADS = "${blas-num-threads}"
        PYTHON_PACKAGE_DIR = "dist-packages"
    }
    output = ["type=cacheonly"]
}

target "scilus-base" {
    inherits = ["dmriqcpy"]
    contexts = {
        dmriqcpy-base = "target:vtk"
    }
    tags = ["scilus-base:local"]
    cache-from = ["type=registry,ref=avcaron/scilus-base"]
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

target "scilpy" {
    dockerfile = "scilpy.Dockerfile"
    context = "./containers/scilpy.context"
    contexts = {
        scilpy-base = "target:vtk"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
        SCILPY_VERSION = "${scilpy-version}"
        BLAS_NUM_THREADS = "${blas-num-threads}"
        VTK_VERSION = "${vtk-version}"
    }
    tags = ["scilpy:local"]
    cache-from = ["type=registry,ref=avcaron/scilpy"]
    output = ["type=docker"]
    pull = true
}

target "dmriqcpy" {
    dockerfile = "dmriqcpy.Dockerfile"
    context = "./containers/dmriqcpy.context"
    contexts = {
        dmriqcpy-base = "target:vtk"
    }
    args = {
        DMRIQCPY_VERSION = "${dmriqcpy-version}"
        PYTHON_VERSION = "${python-version}"
        VTK_VERSION = "${vtk-version}"
    }
    tags = ["dmriqcpy:local"]
    cache-from = ["type=registry,ref=avcaron/dmriqcpy"]
    output = ["type=docker"]
    pull = true
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
        vtk-base = "${vtk-base}"
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
