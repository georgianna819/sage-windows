# Startup configuration for SageMath for Windows
# Sets a few environment variables and initializes files in the user's home
# directory
source /etc/sage-version

# Simply hard-coded for now
export SAGE_ROOT=/opt/sagemath-${SAGE_VERSION}

# Mount the user's real home directory to /home/sage if not already done
if [ ! -f "/etc/fstab.d/${USERNAME}" ]; then
    /usr/local/bin/sage-sethome
fi

# .sage migration--older versions of Sage for Windows put DOT_SAGE in
# ~/.sagemath-${SAGE_VERSION}, but now we are switching over to just
# ~/.sage, and sharing it between versions.
# If the user already has ~/.sage we leave it alone and do nothing.
# Otherwise we move the old ~/.sagemath-${SAGE_VERSION} to ~/.sage.
OLD_DOT_SAGE="${HOME}/.sagemath-${SAGE_VERSION}"
NEW_DOT_SAGE="${HOME}/.sage"
if [ ! -d "$NEW_DOT_SAGE" ]; then
    if [ -d "$OLD_DOT_SAGE" ]; then
        mv "$OLD_DOT_SAGE" "$NEW_DOT_SAGE"
    fi
    # Initialize dot_sage with some defaults
    cp -R "$SAGE_ROOT/dot_sage/"* "$NEW_DOT_SAGE"
fi

# This is needed so that the Python webbrowser module can easily open the
# system browser through Cygwin
export BROWSER=cygstart

# See https://github.com/embray/sage-windows/issues/12
export PYTHONWARNINGS="ignore:not adding directory '' to sys.path"
