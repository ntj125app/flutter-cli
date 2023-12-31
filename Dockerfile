FROM ubuntu:jammy

ENV PATH="/usr/local/flutter-cli/flutter/bin:/usr/local/android-cli/cmdline-tools/bin:/usr/local/android-cli/platform-tools:${PATH}"
ENV FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"

# Install Flutter Dependencies
RUN apt update && apt upgrade -y && apt autoremove -y && \
    apt install -y bash curl file git unzip xz-utils zip libglu1-mesa && \
    mkdir -p /usr/local/flutter-cli && \
    cd /tmp && \
    curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.2-stable.tar.xz -o flutter.tar.xz && \
    tar xf flutter.tar.xz -C /usr/local/flutter-cli && \
    rm -rf flutter.tar.xz && \
    git config --global --add safe.directory /usr/local/flutter-cli/flutter && \
    flutter config --no-analytics && \
    flutter --disable-telemetry && \
    flutter precache

# Install Java
RUN apt install -y openjdk-19-jdk && \
    update-alternatives --set java /usr/lib/jvm/java-19-openjdk-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-19-openjdk-amd64/bin/javac

ENV JAVA_HOME=/usr/lib/jvm/java-19-openjdk-amd64

# Install Android SDK
RUN cd /tmp && \
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -o android-cli.zip && \
    unzip android-cli.zip -d /usr/local/android-cli && \
    rm -rf android-cli.zip && \
    mkdir -p /root/.android && \
    touch /root/.android/repositories.cfg && \
    mkdir -p /usr/local/android-cli/cmdline-tools/latest && \
    yes | sdkmanager --licenses --sdk_root=/usr/local/android-cli && \
    sdkmanager --update --sdk_root=/usr/local/android-cli && \
    sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0" "cmdline-tools;latest" --sdk_root=/usr/local/android-cli

# Privilege drop
RUN adduser --disabled-password --gecos '' flutter && \
    chown -R flutter:flutter /usr/local/flutter-cli && \
    chown -R flutter:flutter /usr/local/android-cli && \
    chown -R flutter:flutter /root/.android

USER flutter

# Check Flutter Version
RUN flutter doctor -v

ENTRYPOINT ["flutter"]