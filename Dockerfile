FROM ubuntu:jammy

ENV PATH="/usr/local/flutter-cli/flutter/bin:/usr/local/android-cli/cmdline-tools/tools/bin:/usr/local/android-cli/platform-tools:/usr/local/android-cli/tools/bin:${PATH}"

# Install Flutter Dependencies
RUN apt update && apt upgrade -y && apt autoremove -y && \
    apt install -y bash curl file git mkdir rm unzip which xz-utils zip libglu1-mesa && \
    mkdir -p /usr/local/flutter-cli && \
    cd /tmp && \
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.2-stable.tar.xz -o flutter.tar.xz && \
    tar xf flutter.tar.xz -C /usr/local/flutter-cli && \
    rm -rf flutter.tar.xz && \
    flutter config --no-analytics && \
    flutter precache

# Install Android SDK
RUN cd /tmp && \
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -o android-cli.zip && \
    unzip android-cli.zip -d /usr/local/android-cli && \
    rm -rf android-cli.zip && \
    mkdir -p /root/.android && \
    touch /root/.android/repositories.cfg && \
    yes | sdkmanager --licenses && \
    sdkmanager --update && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" "cmdline-tools;latest" && \
    yes | sdkmanager --licenses

# Check Flutter Version
RUN flutter doctor -v