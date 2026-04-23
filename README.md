# guix-geng-project
MPE Research Project for Guix

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
        (branch "main")))
```

## Installing custom extension package - myext
`myext` is a Guix package that builds and installs `LoadableMVoxMeshGen`, a Slicer C++ loadable module version of mvox.
</br>
To install:
```
guix pull
guix install myext
```
To load the module in Slicer:
```
Slicer --additional-module-paths \
  $(guix package --list-installed | grep myext | awk '{print $4}')/lib/Slicer-5.8/qt-loadable-modules
```
What gets installed:
```
<store>/myext-0.1/lib/Slicer-5.8/qt-loadable-modules/libqSlicerLoadableMVoxMeshGenModule.so
<store>/myext-0.1/lib/Slicer-5.8/qt-loadable-modules/libvtkSlicerLoadableMVoxMeshGenModuleLogic.so
```
