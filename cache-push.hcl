# cache-push.hcl

BUILD_N_THREADS="6"

target "scilus" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus"]
}

target "scilus-base" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus-base"]
}

target "scilpy" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilpy"]
}

target "dmriqcpy" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:dmriqcpy"]
}

target "cmake" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:cmake"]
}

target "vtk" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:vtk"]
}

target "ants" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:ants"]
}

target "mrtrix" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:mrtrix"]
}

target "fsl" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:fsl"]
}

target "scilus-python" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus-python"]
}

target "scilus-scilpy" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus-scilpy"]
}

target "scilus-nextflow" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus-nextflow"]
}

target "scilus-vtk" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus-vtk"]
}

target "scilus-flows" {
    cache-to = ["type=registry,mode=max,ref=avcaron/build-cache:scilus-flows"]
}
