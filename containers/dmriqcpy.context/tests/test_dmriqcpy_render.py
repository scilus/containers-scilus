

def test_dmriqcpy_dti(script_runner):
    from dipy.core.gradients import gradient_table
    from dipy.data import get_sphere
    import dipy.reconst.dti as dti
    from dipy.sims.voxel import multi_tensor
    import nibabel as nib
    import numpy as np
    from os import makedirs
    from os.path import join
    import tempfile

    space_shape= (3, 3, 3)
    vol_shape = space_shape + (3, 6)
    tensor_volume = np.zeros(vol_shape)
    tensor_volume[..., 0, :] = [3E-3, 3E-3, 3E-3, 1., 0., 0.]
    tensor_volume[
        (0, 1, 2),
        (1, 1, 1),
        (1, 1, 1),
        0
    ] = [1.7E-3, 4E-4, 4E-4, 1., 0., 0.]
    tensor_volume[
        (1, 1, 1),
        (0, 1, 2),
        (1, 1, 1),
        1
    ] = [1.7E-3, 4E-4, 4E-4, 0., 1., 0.]
    tensor_volume[
        (1, 1, 1),
        (1, 1, 1),
        (0, 1, 2),
        1
    ] = [1.7E-3, 4E-4, 4E-4, 0., 0., 1.]

    wm_mask = np.zeros(space_shape, dtype=bool)
    wm_mask[
        (1, 0, 1, 1, 2, 1, 1),
        (0, 1, 1, 1, 1, 2, 1),
        (1, 1, 0, 1, 1, 1, 2),
    ] = True
    gm_mask = np.zeros(space_shape, dtype=bool)
    gm_mask[
        (1, 0, 1, 2, 1, 1),
        (0, 1, 1, 1, 2, 1),
        (1, 1, 0, 1, 1, 2),
    ] = True
    csf_mask = np.zeros(space_shape, dtype=bool)
    csf_mask[
        (0, 0, 0, 0, 2, 2, 2, 2),
        (0, 0, 2, 2, 0, 0, 2, 2),
        (0, 2, 0, 2, 0, 2, 0, 2)
    ] = True

    gtab = gradient_table(
        np.concatenate(([0], np.ones((100,), dtype=int) * 1000)),
        np.concatenate(
            ([[0], [0], [0]], get_sphere('repulsion100').vertices.T),
            axis=1
        )
    )
    def _generate_signal(config):
        _c = config.reshape((3, 6))
        _mask = np.all(np.isclose(_c[:, 3:], 0.), axis=1)
        if np.sum(_mask) == 0:
            return 0.
        else:
            return multi_tensor(
                gtab,
                _c[_mask, :3],
                1.,
                _c[_mask, 3:],
                [100. / np.sum(_mask) for _ in range(np.sum(_mask))],
                20
            )[0]

    tensor_volume = tensor_volume.reshape((-1, 18))
    signal = np.apply_along_axis(_generate_signal, 1, tensor_volume)
    model = dti.TensorModel(gtab)
    fit = model.fit(signal)

    affine = np.eye(4)
    def _get_image(_data):
        _sh = space_shape + _data.shape[1:]
        return nib.Nifti1Image(_data.reshape(_sh), affine)
    
    with tempfile.TemporaryDirectory() as temp_dir:
        nib.save(_get_image(fit.md), join(temp_dir, "md.nii.gz"))
        nib.save(_get_image(fit.ad), join(temp_dir, "ad.nii.gz"))
        nib.save(_get_image(fit.rd), join(temp_dir, "rd.nii.gz"))
        nib.save(_get_image(fit.fa), join(temp_dir, "fa.nii.gz"))
        nib.save(_get_image(fit.directions), join(temp_dir, "evecs_v1.nii.gz"))
        nib.save(
            _get_image(np.abs(signal - fit.predict(gtab))),
            join(temp_dir, "residual.nii.gz")
        )
        nib.save(
            nib.Nifti1Image(wm_mask.astype(np.uint8), affine),
            join(temp_dir, "wm.nii.gz")
        )
        nib.save(
            nib.Nifti1Image(gm_mask.astype(np.uint8), affine),
            join(temp_dir, "gm.nii.gz")
        )
        nib.save(
            nib.Nifti1Image(csf_mask.astype(np.uint8), affine),
            join(temp_dir, "csf.nii.gz")
        )

        makedirs(join(temp_dir, "dmriqc_dti_run"))
        ret = script_runner.run(
            "dmriqc_dti.py",
            join(temp_dir, "dmriqc_dti_run"),
            "--fa", join(temp_dir, "fa.nii.gz"),
            "--md", join(temp_dir, "md.nii.gz"),
            "--ad", join(temp_dir, "ad.nii.gz"),
            "--rd", join(temp_dir, "rd.nii.gz"),
            "--residual", join(temp_dir, "residual.nii.gz"),
            "--evecs_v1", join(temp_dir, "evecs_v1.nii.gz"),
            "--wm", join(temp_dir, "wm.nii.gz"),
            "--gm", join(temp_dir, "gm.nii.gz"),
            "--csf", join(temp_dir, "csf.nii.gz")
        )

        return ret.success
