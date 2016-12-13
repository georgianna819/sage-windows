# Startup configuration for SageMath for Windows
# Sets a few environment variables and initializes files in the user's home
# directory, and their DOT_SAGE
source /etc/sage-version

# Simply hard-coded for now
export SAGE_ROOT=/opt/sagemath-${SAGE_VERSION}

# In Cygwin a user's home directory is normally /home/<windows username>
# where <windows username> may contain spaces and more or less arbitrary
# unicode characters, to which many applications included in Sage are
# not friendly
#
# So we create a /dot_sage mount point linking to ${HOME}/.sagemath-7.4
# in the user's fstab.d (fstab.d should be world-writable)
REAL_DOT_SAGE=${HOME}/.sagemath-${SAGE_VERSION}
export DOT_SAGE=/dot_sage

if [ ! -d "${REAL_DOT_SAGE}" ]; then
    mkdir "${REAL_DOT_SAGE}"
    cp -r ${SAGE_ROOT}/dot_sage/* "${REAL_DOT_SAGE}"
fi

if [ ! -d "${DOT_SAGE}" ]; then
    # fstab cannot contain spaces in path names
    # some other special characters should be escaped too but for now space is
    # the most likely suspicious character
    safe_dot_sage=$(echo "${REAL_DOT_SAGE}" | sed 's/ /\\040/g')
    echo "${safe_dot_sage} /dot_sage none bind" > "/etc/fstab.d/${USERNAME}"
    mount -a
fi

# This is needed so that the Python webbrowser module can easily open the
# system browser through Cygwin
export BROWSER=cygstart

# See https://github.com/embray/sage-windows/issues/12
export PYTHONWARNINGS="ignore:not adding directory '' to sys.path"
