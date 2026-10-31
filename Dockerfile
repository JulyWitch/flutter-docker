FROM ghcr.io/gmeligio/flutter-android:3.35.7

# Install the zip utility (needed to package artifacts such as web builds).
# The base image runs as a non-root user (flutter), so switch to root for
# the install and switch back — the same pattern the base image uses.
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends zip jq python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Telethon uploads build outputs to Telegram from a user account
# (scripts/upload_telegram.py in the client repo). python-socks adds
# TELEGRAM_PROXY support; cryptg speeds up large (150-200 MB) uploads.
# PIP_BREAK_SYSTEM_PACKAGES allows a system-wide install on PEP 668
# distros and is ignored by older pip.
RUN PIP_BREAK_SYSTEM_PACKAGES=1 python3 -m pip install --no-cache-dir \
        telethon "python-socks[asyncio]" cryptg \
    && python3 -c "import telethon, python_socks, cryptg"
USER flutter:flutter

# Accept licenses (no-op if already accepted in the base image) and install
# the specific Android build-tools version needed
RUN yes | sdkmanager --licenses > /dev/null || true
RUN yes | sdkmanager --install "build-tools;35.0.0" || true
RUN yes | sdkmanager --install "platforms;android-31" || true
RUN yes | sdkmanager --install "platforms;android-33" || true
RUN yes | sdkmanager --install "platforms;android-34" || true
RUN yes | sdkmanager --install "platforms;android-35" || true

# Verify the install (fails the build early if something went wrong)
RUN sdkmanager --list_installed | grep "build-tools;35.0.0"

# Enable the Flutter web SDK and predownload the web engine artifacts
# (dart2js, dartdevc, canvas kit, ...) so `flutter build web` doesn't
# stall on a lazy download during the actual build
RUN flutter config --enable-web \
    && flutter precache --web
