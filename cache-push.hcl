# cache-push.hcl

BUILD_N_THREADS="6"

variable "dockerhub-user-push" {
    default = "avcaron"
}

target "scilus" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus"]
}

target "scilus-base" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-base"]
}

target "scilpy-base" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilpy"]
}

target "dmriqcpy-base" {
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

target "scilus-flows" {
    cache-to = ["type=registry,mode=max,ref=${dockerhub-user-push}/build-cache:scilus-flows"]
}
