# Evaluating GNU Guix as a Secure and Reproducible Operating System for Software as a Medical Device
MPE Research Project 2025-2026

## Channels.scm used:
```
(list (channel
		(name 'guix)
		(url "https://git.guix.gnu.org/guix.git")
		(commit "ba516ec"))
      (channel
        (name 'systole)
        (url "https://github.com/SystoleOS/guix-systole.git")
        (branch "main")
		(commit "3b42810"))
      (channel
        (name 'mvox)
        (url "https://github.com/benzwick/guix-mvox.git")
        (branch "main"))
      (channel
        (name 'guix-geng-project)
        (url "https://github.com/DavinhDang/guix-geng-project.git")
        (branch "main"))
	  (channel
		(name 'slicer-cbm)
		(url "https://github.com/SlicerCBM/Guix-SlicerCBM.git")
		(branch "main"))
	  (channel
		(name 'explicitsim)
		(url "https://github.com/benzwick/guix-explicitsim")
		(branch "main")))
```

## Installing custom extension package - myext
`myext` is a Guix package that builds and installs `LoadableMVoxMeshGen`, a Slicer C++ loadable module version of mvox.
</br>
For SlicerCustomAppTemplate:
First create a manifest.scm:
```
(specifications->manifest
 '("slicer-custom-app-template"
   "myext-custom-app"
   "mvox"
   "slicer-terminologies-custom-app"
   "slicer-subjecthierarchy-custom-app"
   "slicer-colors-custom-app"
   "slicer-annotations-custom-app"
   "slicer-units-custom-app"
   "slicer-cameras-custom-app"
   "slicer-data-custom-app"
   "slicer-volumes-custom-app"
   "slicer-models-custom-app"
   "slicer-markups-custom-app"
   "slicer-transforms-custom-app"
   "slicer-segmentations-custom-app"))
```
Then install using:
```
guix package -manifest=path/to/manifest.scm
```
To undo changes:
```
guix package --roll-back
```
