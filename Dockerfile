FROM ghcr.io/gmeligio/flutter-android:3.35.7

# Accept licenses (no-op if already accepted in the base image) and install
# the specific Android build-tools version needed
RUN yes | sdkmanager --licenses > /dev/null || true
RUN yes | sdkmanager --install "build-tools;35.0.0" || true
RUN yes | sdkmanager --install "platforms;android-34" || true
RUN yes | sdkmanager --install "platforms;android-35" || true

# Verify the install (fails the build early if something went wrong)
RUN sdkmanager --list_installed | grep "build-tools;35.0.0"
