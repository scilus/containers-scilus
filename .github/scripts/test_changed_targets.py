import unittest

from changed_targets import select_targets


class SelectTargetsTests(unittest.TestCase):
    def test_scientific_python_update_rebuilds_consumers(self):
        result = select_targets(
            ["docker-bake.override.hcl"],
            override_diff='+scilpy-revision = "2.3.0"\n',
        )
        self.assertEqual(result["targets"], ["scilpy", "scilus", "scilus-flows"])
        self.assertEqual(result["primary"], ["scilpy", "scilus"])
        self.assertEqual(result["flows"], ["scilus-flows"])

    def test_runner_update_does_not_rebuild_other_images(self):
        result = select_targets(
            ["docker-bake.override.hcl"],
            override_diff='-actions-runner-version="2.319.1"\n+actions-runner-version="2.320.0"\n',
        )
        self.assertEqual(result["targets"], ["actions-runner"])

    def test_base_image_update_rebuilds_all_images(self):
        result = select_targets(
            ["docker-bake.override.hcl"],
            override_diff='-base-gpu-install-image="old"\n+base-gpu-install-image="new"\n',
        )
        self.assertEqual(
            result["targets"],
            ["scilus-deps", "scilpy", "dmriqcpy", "scilus", "actions-runner", "scilus-flows"],
        )

    def test_unknown_bake_version_fails_closed_to_all_images(self):
        result = select_targets(
            ["docker-bake.override.hcl"],
            override_diff='+future-version = "1.0"\n',
        )
        self.assertEqual(
            result["targets"],
            ["scilus-deps", "scilpy", "dmriqcpy", "scilus", "actions-runner", "scilus-flows"],
        )

    def test_fsl_update_rebuilds_dependency_chain(self):
        result = select_targets(
            ["docker-bake.override.hcl"],
            override_diff='-fsl-version="old"\n+fsl-version="new"\n',
        )
        self.assertEqual(result["targets"], ["scilus-deps", "scilus", "scilus-flows"])


if __name__ == "__main__":
    unittest.main()
