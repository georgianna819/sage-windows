Changelog for the Windows Installer
===================================

0.4.1 (2018-09-24)
------------------

* Added some dependencies to the runtime environment that were necessary
  for compiling Cython code at runtime to work (e.g. `cython()`).

* Improved support for `sage -i`, at least in principle (not all optional
  packages work yet, but one can at least install some of the ones that do
  work).

* Fixed bug preventing `sage-sethome` from working properly.


0.4 (2018-08-10)
----------------

* Added single-user installation mode as the default installation mode--now
  Sage can be installed without Administrator privileges on the system.
  Installing Sage with this mode means users can modify files in their Sage
  installation without Administrator privileges (ideal for tinkering and
  installing additional packages!)

* Reworked how home directories are handled:

  * Now Sage runs under a single "home directory" that is named
    `/home/sage`.  For each user, `/home/sage` actually points by default to
    their Windows profile directory (i.e. `C:\Users\<Username>`).  This is
    consistent with previous versions of Sage for Windows, except that
    `/home/sage/` is used instead of `/home/<Username>/` where `<Username>`
    was your Windows username.  This choice is motivated by compatibility
    with some UNIX software that does not handle spaces or special
    characters in home directories.

  * It is now possible to change the default home directory used for Sage:
    For single-user installs you are asked at install time where you would
    like to set your home directory.  However, it can be changed at any time
    from within the Sage Shell by running `sage-sethome [DIRECTORY]` where
    `[DIRECTORY]` is the Windows path you'd like to set as the home
    directory for Sage.

* Included ImageMagick in the distribution.  This is a dependency of some
  functionality in Sage, such as for converting LaTeX to PNG images for
  displaying in the Sage Notebook.


0.3 (2017-12-15)
----------------

* Added a license agreement page to the install wizard.


0.2 (2017-08-07)
----------------

* Initial version tagged for the SageMath 8.0 release.
