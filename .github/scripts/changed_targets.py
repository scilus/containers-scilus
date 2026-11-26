#!/usr/bin/env python3
import argparse
import json
import re
import sys


TARGET_ORDER = (
    "scilus-deps",
    "scilpy",
    "dmriqcpy",
    "scilus",
    "actions-runner",
    "scilus-flows",
)
PRIMARY_TARGETS = ("scilpy", "dmriqcpy", "scilus", "actions-runner")
ALL_TARGETS = set(TARGET_ORDER)

VERSION_TARGETS = {
    "actions-runner-version": {"actions-runner"},
    "scilpy-revision": {"scilpy", "scilus", "scilus-flows"},
    "dmriqcpy-revision": {"dmriqcpy", "scilus", "scilus-flows"},
    "tractoflow-version": {"scilus-flows"},
    "dmriqc-flow-version": {"scilus-flows"},
    "extractor-flow-version": {"scilus-flows"},
    "rbx-flow-version": {"scilus-flows"},
    "tractometry-flow-version": {"scilus-flows"},
    "register-flow-version": {"scilus-flows"},
    "disconets-flow-version": {"scilus-flows"},
    "freewater-flow-version": {"scilus-flows"},
    "noddi-flow-version": {"scilus-flows"},
    "bst-flow-version": {"scilus-flows"},
    "nextflow-version": {"scilus-flows"},
    "java-version": {"scilus-flows"},
    "fsl-version": {"scilus-deps", "scilus", "scilus-flows"},
    "fsl-installer-version": {"scilus-deps", "scilus", "scilus-flows"},
    "miniconda-version": {"scilus-deps", "scilus", "scilus-flows"},
    "mrtrix-revision": {"scilus-deps", "scilus", "scilus-flows"},
    "ants-revision": {"scilus-deps", "scilus", "scilus-flows"},
    "ants-affine-syn-revision": {"scilus-deps", "scilus", "scilus-flows"},
    "cmake-revision": {"scilus-deps", "scilus", "scilus-flows"},
    "mesa-version": {"scilus-deps", "scilus", "scilus-flows"},
}
SCILPY_AND_DMRIQCPY = {"scilpy", "dmriqcpy", "scilus", "scilus-flows"}
SCILUS_STACK = {"scilus", "scilus-flows"}
SCILUS_WITH_DEPS = {"scilus-deps", "scilus", "scilus-flows"}


def select_targets(paths, override_diff="", manual_target="all"):
    if manual_target != "all":
        if manual_target not in ALL_TARGETS:
            raise ValueError(f"unsupported target: {manual_target}")
        selected = {manual_target}
    else:
        selected = set()
        for path in paths:
            if path in {"docker-bake.hcl", ".github/workflows/docker-builder.yml"}:
                selected.update(ALL_TARGETS)
            elif path == "docker-bake.override.hcl":
                variables = set(
                    re.findall(r"^[+-]\s*([A-Za-z][A-Za-z0-9_-]*)\s*=", override_diff, re.M)
                )
                if not variables:
                    selected.update(ALL_TARGETS)
                else:
                    for variable in variables:
                        if variable in VERSION_TARGETS:
                            selected.update(VERSION_TARGETS[variable])
                        elif variable == "base-gpu-install-image":
                            selected.update(ALL_TARGETS)
                        elif variable == "base-cpu-install-image":
                            selected.update(SCILPY_AND_DMRIQCPY)
                        elif variable == "base-build-image":
                            selected.update(SCILUS_WITH_DEPS)
                        elif variable in {
                            "python-version",
                            "vtk-version",
                        }:
                            selected.update(SCILPY_AND_DMRIQCPY)
                        elif variable in {"uv-version", "gpu"}:
                            selected.update({"scilpy", "scilus", "scilus-flows"})
                        elif variable == "itk-num-threads":
                            selected.update(SCILUS_STACK)
                        elif variable == "blas-num-threads":
                            selected.add("scilpy")
                        elif variable in {"python-wheels-local-version", "wheelhouse-path"}:
                            selected.update(SCILPY_AND_DMRIQCPY)
                        elif variable == "DEPS_TAG":
                            selected.update(SCILUS_STACK)
                        elif variable in {"SCILUS_TAG", "FLOWS_TAG"}:
                            selected.add("scilus-flows")
                        elif variable == "ACR_TAG":
                            selected.add("actions-runner")
                        elif variable in {"dockerhub-user-pull", "dockerhub-user-push"}:
                            selected.update(ALL_TARGETS)
                        else:
                            selected.update(ALL_TARGETS)
            elif path == "containers/actions-runner.Dockerfile":
                selected.add("actions-runner")
            elif path.startswith("containers/scilpy.context/"):
                selected.update({"scilpy", "scilus", "scilus-flows"})
            elif path.startswith("containers/dmriqcpy.context/"):
                selected.update({"dmriqcpy", "scilus", "scilus-flows"})
            elif path.startswith("containers/scilus.context/"):
                selected.update(SCILUS_STACK)
            elif path in {
                "containers/scilus-flows.Dockerfile",
                "containers/nextflow.Dockerfile",
            }:
                selected.add("scilus-flows")
            elif path.startswith("containers/"):
                selected.update(SCILUS_WITH_DEPS)

    ordered = [target for target in TARGET_ORDER if target in selected]
    primary = [target for target in ordered if target in PRIMARY_TARGETS]
    deps = ["scilus-deps"] if "scilus-deps" in selected else []
    flows = ["scilus-flows"] if "scilus-flows" in selected else []
    return {"targets": ordered, "deps": deps, "primary": primary, "flows": flows}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--manual-target", default="all")
    parser.add_argument("paths", nargs="*")
    arguments = parser.parse_args()
    try:
        result = select_targets(
            arguments.paths,
            override_diff=sys.stdin.read(),
            manual_target=arguments.manual_target,
        )
    except ValueError as error:
        print(str(error), file=sys.stderr)
        sys.exit(2)
    print(json.dumps(result))
