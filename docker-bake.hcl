# docker-bake.hcl

# ==============================================================================
# BUILD VARIABLES
# ==============================================================================

variable "base-install-image" {
    default = "ubuntu:22.04"
}

variable "base-build-image" {
    default = "ubuntu:22.04"
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
    default = "6.0.6.4"
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
    default = "3.10"
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

variable "dockerhub-user-pull" {
    default = "scilus"
}

variable "DEPS_TAG" {
}

variable "SCILUS_TAG" {
}

variable "FLOWS_TAG" {
}

# ==============================================================================
# DOCKER BUILDX BAKE TARGETS
# ==============================================================================

group "scilus-flows" {
    targets = ["scilus-flows"]
}

group "scilus" {
    targets = ["scilus", "scilus-test"]
}

group "scilus-deps" {
    targets = ["scilus-fsl"]
}

group "scilpy" {
    targets = ["scilpy", "scilpy-test"]
}

group "dmriqcpy" {
    targets = ["dmriqcpy", "dmriqcpy-test"]
}

# ==============================================================================
# TEST TARGETS
# ==============================================================================

target "scilus-test" {
    name = "scilus-test-${tgt}"
    inherits = ["pytest-base"]
    matrix = {
        tgt = ["scilus", "scilpy", "dmriqcpy", "vtk-omesa"]
    }
    context = "./containers/${tgt}.context"
    contexts = {
        test-base = "target:scilus"
    }
}

target "scilpy-test" {
    name = "scilpy-test-${tgt}"
    inherits = ["pytest-base"]
    matrix = {
        tgt = ["scilpy", "vtk-omesa"]
    }
    context = "./containers/${tgt}.context"
    contexts = {
        test-base = "target:scilpy"
    }
}

target "dmriqcpy-test" {
    name = "dmriqcpy-test-${tgt}"
    inherits = ["pytest-base"]
    matrix = {
        tgt = ["dmriqcpy", "vtk-omesa"]
    }
    context = "./containers/${tgt}.context"
    contexts = {
        test-base = "target:dmriqcpy"
    }
}

target "pytest-base" {
    dockerfile-inline = "FROM test-base\nCOPY /tests /tests\nWORKDIR /tests\nRUN python3 -m pip install pytest pytest_console_scripts && python3 -m pytest"
    output = ["type=cacheonly"]
}

# ==============================================================================
# NEXTFLOW TARGETS
# ==============================================================================

target "scilus-flows" {
    inherits = ["scilus-cache"]
    dockerfile = "scilus-flows.Dockerfile"
    context = "./containers"
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
    tags = [
        notequal("", FLOWS_TAG) ? "scilus/scilus-flows:${FLOWS_TAG}" : "scilus-flows:local"
    ]
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-flows",
        "type=registry,ref=scilus/build-cache:scilus-flows"
    ]
    output = ["type=docker"]
}

target "scilus-nextflow" {
    inherits = ["nextflow"]
    contexts = {
        nextflow-base = notequal("", SCILUS_TAG) ? "docker-image://${dockerhub-user-pull}/scilus:${SCILUS_TAG}" : "target:scilus"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-nextflow",
        "type=registry,ref=scilus/build-cache:scilus-nextflow"
    ]
    output = ["type=cacheonly"]
}

# ==============================================================================
# CONTAINERS TARGETS
# ==============================================================================

target "scilpy" {
    inherits = ["scilpy-base", "scilpy-cache"]
    tags = ["scilpy:local"]
    output = ["type=docker"]
}

target "dmriqcpy" {
    inherits = ["dmriqcpy-base", "dmriqcpy-cache"]
    tags = ["dmriqcpy:local"]
    output = ["type=docker"]
}

# ==============================================================================
# SCILUS BUILD TARGETS
# ==============================================================================

target "scilus" {
    inherits = ["scilus-cache"]
    dockerfile = "scilus.Dockerfile"
    context = "./containers/scilus.context"
    contexts = {
        scilus-base = "target:scilus-scilpy"
    }
    args = {
        SCILPY_VERSION = "${scilpy-version}"
        ITK_NUM_THREADS = "${"itk-num-threads"}"
    }
    tags = [
        notequal("", SCILUS_TAG) ? "scilus/scilus:${SCILUS_TAG}" : "scilus:local"
    ]
    output = ["type=docker"]
}

target "scilus-scilpy" {
    inherits = ["scilpy-base"]
    contexts = {
        scilpy-base = "target:scilus-dmriqcpy"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilpy",
        "type=registry,ref=scilus/build-cache:scilpy"
    ]
}

target "scilus-dmriqcpy" {
    inherits = ["dmriqcpy-base"]
    contexts = {
        dmriqcpy-base = notequal("", DEPS_TAG) ? "docker-image://${dockerhub-user-pull}/scilus-deps:${DEPS_TAG}" : "target:scilus-fsl"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:dmriqcpy",
        "type=registry,ref=scilus/build-cache:dmriqcpy"
    ]
}

target "scilus-fsl" {
    inherits = ["fsl"]
    contexts = {
        fsl-base = "target:scilus-mrtrix"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-deps",
        "type=registry,ref=scilus/build-cache:scilus-deps"
    ]
    tags = [
        notequal("", DEPS_TAG) ? "scilus/scilus-deps:${DEPS_TAG}" : ""
    ]
    output = ["type=docker"]
}

target "scilus-mrtrix" {
    inherits = ["mrtrix"]
    contexts = {
        mrtrix-base = "target:scilus-ants"
    }
}

target "scilus-ants" {
    inherits = ["ants"]
    contexts = {
        ants-base = "target:scilus-vtk"
    }
}

target "scilus-vtk" {
    inherits = ["vtk"]
    contexts = {
        vtk-base = "target:scilus-base"
    }
}

target "scilus-base" {
    dockerfile = "scilus-base.Dockerfile"
    context = "./containers/scilus.context"
    contexts = {
        scilus-image-base = "docker-image://${base-install-image}"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
        SCILPY_VERSION = "${scilpy-version}"
        BLAS_NUM_THREADS = "${blas-num-threads}"
        VTK_VERSION = "${vtk-version}"
        PYTHON_PACKAGE_DIR = "dist-packages"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-base",
        "type=registry,ref=scilus/build-cache:scilus-base"
    ]
    output = ["type=cacheonly"]
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
        PYTHON_PACKAGE_DIR = "dist-packages"
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
        PYTHON_PACKAGE_DIR = "dist-packages"
    }
    output = ["type=cacheonly"]
}

target "fsl" {
    dockerfile = "fsl.Dockerfile"
    context = "./containers/fsl.context"
    target = "fsl-install"
    contexts = {
        fsl-base = "docker-image://${base-install-image}"
        fsl-builder = "docker-image://${base-build-image}"
    }
    args = {
        FSL_VERSION = "${fsl-version}"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:fsl",
        "type=registry,ref=scilus/build-cache:fsl"
    ]
    output = ["type=cacheonly"]
}

target "mrtrix" {
    dockerfile = "mrtrix.Dockerfile"
    context = "./containers"
    target = "mrtrix-install"
    contexts = {
        mrtrix-base = "docker-image://${base-install-image}"
        mrtrix-builder = "docker-image://${base-build-image}"
    }
    args = {
        MRTRIX_BUILD_NTHREADS = "6"
        MRTRIX_VERSION = "${mrtrix-version}"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:mrtrix",
        "type=registry,ref=scilus/build-cache:mrtrix"
    ]
    output = ["type=cacheonly"]
}

target "ants" {
    dockerfile = "ants.Dockerfile"
    context = "./containers"
    target = "ants-install"
    contexts = {
        ants-base = "docker-image://${base-install-image}"
        ants-builder = "target:cmake"
    }
    args = {
        ANTS_BUILD_NTHREADS = "6"
        ANTS_VERSION = "${ants-version}"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:ants",
        "type=registry,ref=scilus/build-cache:ants"
    ]
    output = ["type=cacheonly"]
}

target "vtk" {
    dockerfile = "vtk-omesa.Dockerfile"
    context = "./containers/vtk-omesa.context/"
    target = "vtk-install"
    contexts = {
        vtk-base = "docker-image://${base-install-image}"
        vtk-builder = "target:cmake"
    }
    args = {
        MESA_BUILD_NTHREADS = "6"
        MESA_VERSION = "${mesa-version}"
        VTK_BUILD_NTHREADS = "6"
        VTK_PYTHON_VERSION = "${python-version}"
        VTK_VERSION = "${vtk-version}"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:vtk",
        "type=registry,ref=scilus/build-cache:vtk"
    ]
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
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:cmake",
        "type=registry,ref=scilus/build-cache:cmake"
    ]
    output = ["type=cacheonly"]
}

# ==============================================================================
# CACHE TARGETS
# ==============================================================================

target "scilpy-cache" {
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilpy",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:vtk",
        "type=registry,ref=${dockerhub-user-pull}/scilpy:latest",
        "type=registry,ref=${dockerhub-user-pull}/scilpy:dev",
        "type=registry,ref=scilus/build-cache:scilpy",
        "type=registry,ref=scilus/build-cache:vtk",
        "type=registry,ref=scilus/scilpy:latest",
        "type=registry,ref=scilus/scilpy:dev"
    ]
}

target "dmriqcpy-cache" {
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:dmriqcpy",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:vtk",
        "type=registry,ref=${dockerhub-user-pull}/dmriqcpy:latest",
        "type=registry,ref=${dockerhub-user-pull}/dmriqcpy:dev",
        "type=registry,ref=scilus/build-cache:dmriqcpy",
        "type=registry,ref=scilus/build-cache:vtk",
        "type=registry,ref=scilus/dmriqcpy:latest",
        "type=registry,ref=scilus/dmriqcpy:dev"
    ]
}

target "scilus-flows-cache" {
    inherits = ["scilus-cache"]
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-nextflow",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-flows",
        "type=registry,ref=scilus/build-cache:scilus-nextflow",
        "type=registry,ref=scilus/build-cache:scilus-flows"
    ]
}

target "scilus-cache" {
    inherits = ["scilus-base-cache"]
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-base",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilpy",
        "type=registry,ref=${dockerhub-user-pull}/scilus:latest",
        "type=registry,ref=${dockerhub-user-pull}/scilus:dev",
        "type=registry,ref=${dockerhub-user-pull}/scilus:git-build",
        "type=registry,ref=scilus/build-cache:scilus-base",
        "type=registry,ref=scilus/build-cache:scilus",
        "type=registry,ref=scilus/build-cache:scilpy",
        "type=registry,ref=scilus/scilus:latest",
        "type=registry,ref=scilus/scilus:dev"
    ]
}

target "scilus-base-cache" {
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:scilus-base",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:dmriqcpy",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:fsl",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:mrtrix",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:ants",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:vtk",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:cmake",
        "type=registry,ref=scilus/build-cache:scilus-base",
        "type=registry,ref=scilus/build-cache:dmriqcpy",
        "type=registry,ref=scilus/build-cache:fsl",
        "type=registry,ref=scilus/build-cache:mrtrix",
        "type=registry,ref=scilus/build-cache:ants",
        "type=registry,ref=scilus/build-cache:vtk",
        "type=registry,ref=scilus/build-cache:cmake"
    ]
}