import os
from tempfile import TemporaryDirectory


def test_scilpy_gradient_render(script_runner):
    with TemporaryDirectory() as test_dir:
        res1 = script_runner.run(
            "scil_generate_gradient_sampling",
            "10", "10", "10",
            "sampling",
            "--bvals", "1000", "2000", "3000",
            "--fsl",
            cwd=test_dir
        )

        assert res1.success, res1.stderr

        res2 = script_runner.run(
            "scil_visualize_gradients",
            "--in_gradient_scheme",
            "sampling.bval", "sampling.bvec",
            "--out_basename", "sampling_snap",
            cwd=test_dir
        )

        assert res2.success, res2.stderr
        assert os.path.exists(
            os.path.join(test_dir, "sampling_snap.png"))
