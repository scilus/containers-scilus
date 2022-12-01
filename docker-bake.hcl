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

variable "scilpy-requirements" {
    default = "requirements.1.3.0.frozen"
}

variable "scilpy-test-base" {
    default = "scilpy"
}

variable "dmriqcpy-test-base" {
    default = "dmriqcpy"
}

variable "vtk-test-base" {
    default = "vtk"
}

variable "tractoflow-version" {
    default = "2.3.0"
}

variable "dmriqc-flow-version" {
    default = "0.1.0"
}

variable "extractor-flow-version" {
    default = "master"
}

variable "rbx-flow-version" {
    default = "1.1.0"
}

variable "tractometry-flow-version" {
    default = "1.0.0"
}

variable "register-flow-version" {
    default = "main"
}

variable "disconets-flow-version" {
    default = "0.1.0-rc1"
}

variable "freewater-flow-version" {
    default = "1.0.0"
}

variable "noddi-flow-version" {
    default = "1.0.0"
}

variable "bst-flow-version" {
    default = "1.0.0-rc1"
}

# ==============================================================================
# DOCKER BUILDX BAKE TARGETS
# ==============================================================================

group "scilus-flows" {
    targets = ["scilus-flows", "scilus-test", "scilpy-test"]
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
    cache-to = []
    tags = []
}

target "scilpy-test" {
    inherits = ["${scilpy-test-base}"]
    target = "scilpy-test"
    output = ["type=cacheonly"]
    cache-to = []
    tags = []
}

target "scilus-test" {
    inherits = ["scilus"]
    target = "scilus-test"
    output = ["type=cacheonly"]
    cache-to = []
    tags = []
}

target "vtk-test" {
    inherits = ["${vtk-test-base}"]
    target = "vtk-test"
    output = ["type=cacheonly"]
    cache-to = []
    tags = []
}

# ==============================================================================
# NEXTFLOW TARGETS
# ==============================================================================

target "scilus-flows" {
    dockerfile = "scilus-flows.Dockerfile"
    context = "./containers/scilus-flows.context"
    target = "scilus-flows"
    contexts = {
        flow-base = "target:scilus-nextflow"
    }
    args = {
        TRACTOFLOW_VERSION = "${tractoflow-version}"
        DMRIQCFLOW_VERSION = "${dmriqc-flow-version}"
        EXTRACTORFLOW_VERSION = "${extractor-flow-version}"
        RBXFLOW_VERSION = "${rbx-flow-version}"
        TRACTOMETRYFLOW_VERSION = "${tractometry-flow-version}"
        REGISTERFLOW_VERSION = "${register-flow-version}"
        DISCONETSFLOW_VERSION = "${disconets-flow-version}"
        FREEWATERFLOW_VERSION = "${freewater-flow-version}"
        NODDIFLOW_VERSION = "${noddi-flow-version}"
        BSTFLOW_VERSION = "${bst-flow-version}"
    }
    tags = ["scilus-flows:local"]
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus-flows"]
    output = ["type=docker"]
    pull = true
}

target "scilus-nextflow" {
    inherits = ["nextflow"]
    contexts = {
        nextflow-base = "target:scilus"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus-nextflow"]
    output = ["type=cacheonly"]
}

# ==============================================================================
# CONTAINERS TARGETS
# ==============================================================================

target "scilpy" {
    inherits = ["scilpy-base"]
    tags = ["scilpy:local"]
    cache-from = ["type=registry,ref=avcaronscilpy"]
    output = ["type=docker"]
    pull = true
}

target "scilus" {
    dockerfile = "scilus.Dockerfile"
    context = "./containers/scilus.context/"
    target = "scilus"
    contexts = {
        scilus-base = "target:scilus-scilpy"
    }
    args = {
        FROZEN_REQUIREMENTS = "${scilpy-requirements}"
        ITK_NUM_THREADS = "${itk-num-threads}"
        SCILPY_VERSION = "${scilpy-version}"
    }
    tags = ["scilus:local"]
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus"]
    output = ["type=docker"]
    pull = true
}

target "scilus-base" {
    inherits = ["dmriqcpy-base"]
    contexts = {
        dmriqcpy-base = "target:scilus-vtk"
    }
    tags = ["scilus-base:local"]
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus-base"]
}

target "dmriqcpy" {
    inherits = ["dmriqcpy-base"]
    tags = ["dmriqcpy:local"]
    cache-from = ["type=registry,ref=avcaron/build-cache:dmriqcpy"]
    output = ["type=docker"]
    pull = true
}

# ==============================================================================
# SPECIALIZED BUILD TARGETS
# ==============================================================================

target "scilus-scilpy" {
    inherits = ["scilpy-base"]
    contexts = {
        scilpy-base = "target:scilus-base"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
        SCILPY_VERSION = "${scilpy-version}"
        BLAS_NUM_THREADS = "${blas-num-threads}"
        PYTHON_PACKAGE_DIR = "dist-packages"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus-scilpy"]
}

target "scilus-vtk" {
    inherits = ["vtk"]
    contexts = {
        vtk-base = "target:scilus-python"
        vtk-builder = "target:cmake"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus-vtk"]
}

# ==============================================================================
# BUILD TARGETS
# ==============================================================================

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

target "scilus-python" {
    dockerfile = "scilus-python.Dockerfile"
    context = "./containers"
    contexts = {
        python-base = "target:fsl"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:scilus-python"]
    output = ["type=cacheonly"]
}

target "scilpy-base" {
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
    output = ["type=cacheonly"]
}

target "dmriqcpy-base" {
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
    output = ["type=cacheonly"]
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
    cache-from = ["type=registry,ref=avcaron/build-cache:fsl"]
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
        MRTRIX_BUILD_NTHREADS = "6"
        MRTRIX_VERSION = "${mrtrix-version}"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:mrtrix"]
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
        ANTS_BUILD_NTHREADS = "6"
        ANTS_VERSION = "${ants-version}"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:ants"]
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
        MESA_BUILD_NTHREADS = "6"
        MESA_VERSION = "${mesa-version}"
        VTK_BUILD_NTHREADS = "6"
        VTK_PYTHON_VERSION = "${python-version}"
        VTK_VERSION = "${vtk-version}"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:vtk"]
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
        CMAKE_BUILD_NTHREADS = "6"
        CMAKE_VERSION = "${cmake-version}"
    }
    cache-from = ["type=registry,ref=avcaron/build-cache:cmake"]
    output = ["type=cacheonly"]
}
