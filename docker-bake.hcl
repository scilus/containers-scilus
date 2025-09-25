# docker-bake.hcl

# ==============================================================================
# BUILD VARIABLES
# ==============================================================================

variable "base-gpu-install-image" {
    default = null
}

variable "base-cpu-install-image" {
    default = null
}

variable "base-build-image" {
    default = null
}

variable "actions-runner-version" {
    default = null
}

variable "ants-revision" {
    default = null
}

variable "cmake-revision" {
    default = null
}

variable "dmriqcpy-revision" {
    default = null
}

variable "fsl-version" {
    default = null
}

variable "fsl-installer-version" {
    default = null
}

variable "miniconda-version" {
    default = null
}

variable "mrtrix-revision" {
    default = null
}

variable "scilpy-revision" {
    default = null
}

variable "mesa-version" {
    default = null
}

variable "vtk-version" {
    default = null
}

variable "python-version" {
    default = null
}

variable "uv-version" {
    default = null
}

variable "gpu" {
    default = false
}

variable "nextflow-version" {
    default = null
}

variable "java-version" {
    default = null
}

variable "itk-num-threads" {
    default = null
}

variable "blas-num-threads" {
    default = null
}

variable "tractoflow-version" {
    default = null
}

variable "dmriqc-flow-version" {
    default = null
}

variable "extractor-flow-version" {
    default = null
}

variable "rbx-flow-version" {
    default = null
}

variable "tractometry-flow-version" {
    default = null
}

variable "register-flow-version" {
    default = null
}

variable "disconets-flow-version" {
    default = null
}

variable "freewater-flow-version" {
    default = null
}

variable "noddi-flow-version" {
    default = null
}

variable "bst-flow-version" {
    default = null
}

variable "dockerhub-user-pull" {
    default = "scilus"
}

variable "python-wheels-local-version" {
    default = "scilus"
}

variable "wheelhouse-path" {
    default = "/wheelhouse"
}

variable "DEPS_TAG" {
}

variable "SCILUS_TAG" {
}

variable "FLOWS_TAG" {
}

variable "ACR_TAG" {
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

function "stamp_tag" {
    params = [base_tag, stamp]
    result = ["${base_tag}", "${base_tag}-${formatdate("YYYYMMDD", stamp)}"]
}

# ==============================================================================
# DOCKER BUILDX BAKE TARGETS
# ==============================================================================

group "actions-runner" {
    targets = ["actions-runner"]
}

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
        tgt = ["scilus", "scilpy"]
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
        tgt = ["scilpy"]
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
        tgt = ["dmriqcpy"]
    }
    context = "./containers/${tgt}.context"
    contexts = {
        test-base = "target:dmriqcpy"
    }
}

target "pytest-base" {
    dockerfile-inline = "FROM test-base\nWORKDIR /tests\nRUN --mount=type=bind,source=./tests,target=/tests uv pip install pytest-xdist && uv run --active pytest --html=/tmp/pytest.html --junit-xml=/tmp/junit.xml ."
    output = ["type=cacheonly"]
}

# ==============================================================================
# ACTION RUNNER TARGETS
# ==============================================================================

target "actions-runner" {
    dockerfile = "actions-runner.Dockerfile"
    context = "./containers"
    target = "actions-runner"
    contexts = {
        actions-runner-base = "docker-image://ghcr.io/actions/actions-runner:${actions-runner-version}"
    }
    args = {
        RUNNER_VERSION = "${actions-runner-version}"
        CONTAINER_INSTALL_USER = "root"
        CONTAINER_RUN_USER = "runner"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:actions-runner",
        "type=registry,ref=scilus/build-cache:actions-runner"
    ]
    output = ["type=docker"]
    tags = notequal("", ACR_TAG) ? stamp_tag("scilus/actions-runner:${ACR_TAG}", timestamp()) : ["actions-runner:local"]
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
    tags = notequal("", FLOWS_TAG) ? stamp_tag("scilus/scilus-flows:${FLOWS_TAG}", timestamp()) : ["scilus-flows:local"]
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
        ITK_NUM_THREADS = "${itk-num-threads}"
        SCILPY_REVISION = "${scilpy-revision}"
        VTK_VERSION = "${vtk-version}"
    }
    tags = notequal("", SCILUS_TAG) ? stamp_tag("scilus/scilus:${SCILUS_TAG}", timestamp()) : ["scilus:local"]
    output = ["type=docker"]
}

target "scilus-scilpy" {
    inherits = ["scilpy-base"]
    contexts = {
        scilpy-base = notequal("", DEPS_TAG) ? "docker-image://${dockerhub-user-pull}/scilus-deps:${DEPS_TAG}" : "target:scilus-fsl"
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
    tags = notequal("", DEPS_TAG) ? stamp_tag("scilus/scilus-deps:${DEPS_TAG}", timestamp()) : []
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
        ants-base = "target:scilus-base"
    }
}

target "scilus-base" {
    dockerfile = "scilus-base.Dockerfile"
    context = "./containers/scilus.context"
    contexts = {
        scilus-image-base = "docker-image://${base-gpu-install-image}"
    }
    args = {
        PYTHON_VERSION = "${python-version}"
        GPU = "${gpu}"
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
        scilpy-base = gpu ? "docker-image://${base-gpu-install-image}" : "docker-image://${base-cpu-install-image}"
    }
    args = {
        VTK_VERSION = "${vtk-version}"
        PYTHON_VERSION = "${python-version}"
        UV_VERSION = "${uv-version}"
        GPU = "${gpu}"
        SCILPY_REVISION = "${scilpy-revision}"
        BLAS_NUM_THREADS = "${blas-num-threads}"
    }
    output = ["type=cacheonly"]
}

target "dmriqcpy-base" {
    dockerfile = "dmriqcpy.Dockerfile"
    context = "./containers/dmriqcpy.context"
    contexts = {
        dmriqcpy-base = "docker-image://${base-gpu-install-image}"
    }
    args = {
        DMRIQCPY_REVISION = "${dmriqcpy-revision}"
        PYTHON_VERSION = "${python-version}"
        PYTHON_PACKAGE_DIR = "dist-packages"
        VTK_VERSION = "${vtk-version}"
    }
    output = ["type=cacheonly"]
}

target "fsl" {
    dockerfile = "fsl.Dockerfile"
    context = "./containers/fsl.context"
    target = "fsl-install"
    contexts = {
        fsl-base = "docker-image://${base-gpu-install-image}"
        fsl-builder = "docker-image://${base-build-image}"
    }
    args = {
        FSL_VERSION = "${fsl-version}"
        FSL_INSTALLER_VERSION = "${fsl-installer-version}"
        MINICONDA_VERSION = "${miniconda-version}"
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
        mrtrix-base = "docker-image://${base-gpu-install-image}"
        mrtrix-builder = "docker-image://${base-build-image}"
    }
    args = {
        MRTRIX_BUILD_NTHREADS = "6"
        MRTRIX_REVISION = "${mrtrix-revision}"
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
        ants-base = "docker-image://${base-gpu-install-image}"
        ants-builder = "target:cmake"
    }
    args = {
        ANTS_BUILD_NTHREADS = "6"
        ANTS_REVISION = "${ants-revision}"
    }
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:ants",
        "type=registry,ref=scilus/build-cache:ants"
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
        CMAKE_REVISION = "${cmake-revision}"
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
        "type=registry,ref=${dockerhub-user-pull}/scilpy:latest",
        "type=registry,ref=${dockerhub-user-pull}/scilpy:dev",
        "type=registry,ref=scilus/build-cache:scilpy",
        "type=registry,ref=scilus/scilpy:latest",
        "type=registry,ref=scilus/scilpy:dev"
    ]
}

target "dmriqcpy-cache" {
    cache-from = [
        "type=registry,ref=${dockerhub-user-pull}/build-cache:dmriqcpy",
        "type=registry,ref=${dockerhub-user-pull}/dmriqcpy:latest",
        "type=registry,ref=${dockerhub-user-pull}/dmriqcpy:dev",
        "type=registry,ref=scilus/build-cache:dmriqcpy",
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
        "type=registry,ref=${dockerhub-user-pull}/build-cache:fsl",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:mrtrix",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:ants",
        "type=registry,ref=${dockerhub-user-pull}/build-cache:cmake",
        "type=registry,ref=scilus/build-cache:scilus-base",
        "type=registry,ref=scilus/build-cache:fsl",
        "type=registry,ref=scilus/build-cache:mrtrix",
        "type=registry,ref=scilus/build-cache:ants",
        "type=registry,ref=scilus/build-cache:cmake"
    ]
}