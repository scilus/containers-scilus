Container update using Github workflows
=======================================

Container updating per say is not done using this repository, but other 
repositories, that require for a docker image and have defined their recipe(s) 
in the [build system](docker-bake.md). Only one set of images is built using 
releases on this repository, `scilus` and `scilus-nextflow`, containing all the 
shared dependencies of the `Scilus` ecosystem that are used by most processing 
flows.

***DO NOT USE THE GITHUB RELEASE MECHANISM TO CREATE NEW CONTAINERS RELEASE***

___

Triggering a release
--------------------

To create a new release of either `scilus` or `scilus-nextflow`, use the 
[Release Deployment](.github/workflows/release.yml) workflow. To run, it will 
ask for a short description of the changes, which is optional. All version 
changes will be automatically added to the description by the release workflow. 
Follow this [link](https://github.com/scilus/containers-scilus/actions/workflows/create-release.yml) 
to trigger the workflow.

___

Manually triggering an image build
----------------------------------

Sometimes, it can be handy to generate a container without creating a release on 
`Github` or having the hassle to refer to a remote repository to do so. The 
global builder pipeline comes equiped with a trigger to build an image to a 
given repository on `dockerhub` at a specified tag. The built will profit of all 
available online cache. Follow this [link](https://github.com/scilus/containers-scilus/actions/workflows/docker-builder.yml) 
to trigger the workflow.

___

Servicing a container on a remote repository
--------------------------------------------

The global builder is designed as a `reusable workflow`, which can be integrated 
in any other repositories' workflow to build available images in the build 
system. Inputs and secrets needed for the workflow to run can be found in the 
[workflow file](.github/workflows/docker-builder.yml). To implant the builder in 
a remote workflow, refer to the [Github documentation](https://docs.github.com/en/actions/using-workflows/reusing-workflows#calling-a-reusable-workflow).
