# cache-push.hcl

BUILD_N_THREADS="6"

variable "dockerhub-user-push" {
    default = "scilus"
}

target "scilus" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus"]
}

target "scilus-base" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-base"]
}

target "scilpy" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilpy"]
}

target "dmriqcpy" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:dmriqcpy"]
}

target "cmake" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:cmake"]
}

target "vtk" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:vtk"]
}

target "ants" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:ants"]
}

target "mrtrix" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:mrtrix"]
}

target "fsl" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:fsl"]
}

target "scilus-python" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-python"]
}

target "scilus-scilpy" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-scilpy"]
}

target "scilus-nextflow" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-nextflow"]
}

target "scilus-vtk" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-vtk"]
}

target "scilus-flows" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-flows"]
}
