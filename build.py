"""
Currently just a hand-written and fairly informal list of manual steps for
performing the build.  Will be turned into a script, which may not even be
in the form of a single Python script, but I just called it 'build.py' for
now.
"""

# 1. Download setup.exe
# 2. Install bash and other minimal system requirements
#    Include this NOTE: This list was collected by manually running setup.exe,
#    deslecting all default packages, then installing just bash and base-files,
#    and a few dependencies needed for apt-cyg: coreutils, findutils, tar,
#    grep, wget, hostname, gawk, bzip2, gzip, then accepting all their
#    dependencies as well (which of course pulls in cygwin itself, and any
#    other required minimal set of utilities and libraries--this set is even
#    smaller than the default cygwin base system).  The list was then generated
#    by running `cygcheck -c -d | tail -n +3 > cygwin-bootstrap.list`
# 3. Install apt-cyg into the new cygwin's /usr/local/bin
# 4. Run build Cygwin's bash and use apt-cyg to install remaining required
#    packages which wil be read from a text file (which will be determined
#    mostly by trial and error) (note: this and the previous step could
#    probably just be melded into step 2 by installing the full dependency list
#    up front--I think for automated builds there's no particular advantage to
#    involving apt-cyg if we already have the full list of dependencies)
# 5. Make /opt in the new cygwin
# 6. git clone sage sources to /opt/sagemath-<version> (for automation purposes
#    just use the git:// URL)
# 7. Checkout the branch/tag to build (perhaps combine with the previous step)
# 8. cd into /opt/sagemath-7.4 and run
#        $ make configure
# 9. Run
#        $ ./configure --with-blas=atlas
# 10. Run
#        $ SAGE_NUM_THREADS=1 \
#          SAGE_INSTALL_CCACHE=yes \
#          CCACHE_DIR=</path/to/real/home>/.ccache \
#          SAGE_FAT_BINARY=yes \
#          SAGE_ATLAS_LIB=/usr \
#          make start
#    Where </path/to/real/home> should be the path (through /cygdrive/c, most
#    likely) to your home directory on the host system from which this Cygwin
#    instance is being run--this is to allow it to share your normal .ccache
#    directory.  Or, if you like, you can use a separate .ccache just for Sage
#    builds.
# 11. Upgrade the installed pip--this is annoying but required for some
#     patches to how sage runs pip to work properly.  This is only required
#     for sage 7.4 which uses an older version of pip by default (maybe we
#     could patch it in the 7.4-cygwn branch to use a newer version by
#     default):
#         $ ./sage -pip install --upgrade pip
# 12. From within the build Cygwin, run the sage_cygwin_packages script
#     and output its results to cygwin-sage-runtime.list
# 13. Make a new Cygwin install inside build/app relative to this build
#     script (or an optional alternative build dir); install all the packages
#     listed in cygwin-sage-runtime.list
#         $ setup-x86_64.exe --site ftp://mirrors.kernel.org/sourceware/cygwin/ \
#           --local-package-dir "$(cygpath -w -a download)" \
#           --root "$(cygpath -w -a build/app) \
#           --arch x86_64 --no-admin --no-shortcuts --quiet-mode \
#           --packages $(cat cygwin-sage-runtime.list | awk '{print $1}' | \
#                        tr '\n' ',' | sed 's/,$//')
#
#     TODO: Right now using a hard-coded mirror, but in the future what we
#     really want to ensure reproducibility is a custom mirror with the exact
#     package versions we're building with
#     TODO: In fact, using Cygwin's setup.exe for this purpose is quite noisy
#     and a pain in the ass; when we set up our own local mirror it should
#     contain only exactly the packages we need (via a custom setup.ini) and
#     we can just install all those packages directly by unpacking them
# 14. Clean up a few files from the Cygwin installation--namely the Cygwin.bat
#     and icons:
#         $ rm -f build/app/Cygwin*.{bat,ico}
# 15. Copy the /opt directory from the *build* Cygwin into the *runtime*
#     Cygwin in build/app, then perform the following cleanup (at a minimum)
#     from within the $SAGE_ROOT in build/app (/opt/sagemath-<version>)
#         $ rm -rf bootstrap config* logs m4 Makefile upstream \
#                  local/var/tmp/sage/build/* local/var/lock/* \
#                  src/build local/share/doc/sage/doctrees .git*
# 16. Install the files in cygwin_extras by just
#         $ cp -r cygwin_extras/* build/app/
# 17. Install the /etc/sage-version file:
#         $ echo "SAGE_VERSION=<version>" > build/app/etc/sage-version
#     where <version> should be the actual version string, like "7.4"
# 19. Add the tmp and home mounts to /etc/fstab:
#         $ echo 'none /tmp usertemp binary,posix=0 0 0' >> build/app/etc/fstab
#         $ echo 'C:\Users /home ntfs binary,posix=1,acl 0 0' >> build/app/etc/fstab
# 21. Generate the symlinks.lst file:
#         $ (cd build/app/ && find . -type l) > build/app/etc/symlinks.lst
# 22. Run inno-setup
