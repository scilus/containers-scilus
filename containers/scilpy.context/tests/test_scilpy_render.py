

def test_scilpy_gradient_render(script_runner):
    res1 = script_runner.run(
        "scil_generate_gradient_sampling.py",
        "10", "10", "10",
        "sampling",
        "--bvals", "1000", "2000", "3000",
        "--fsl"
    )

    assert res1

    res2 = script_runner.run(
        "scil_visualize_gradients.py",
        "sampling.bval", "sampling.bvec",
        "--out_basename", "sampling_snap"
    )

    assert res2
