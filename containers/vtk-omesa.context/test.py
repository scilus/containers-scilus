import vtk

version = vtk.vtkVersion()
print("VTK version : {}".format(version.GetVTKVersion()))
