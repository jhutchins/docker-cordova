FROM node:6

MAINTAINER Jeff Hutchins <jeff@nti.io>
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" \
    ANDROID_BUILD_TOOLS_VERSION=26.0.1 \
    ANDROID_APIS="android-26" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    GRADLE_URL="https://downloads.gradle.org/distributions/gradle-4.2-bin.zip" \
    ANDROID_HOME="/opt/android" \
    CORDOVA_VERSION=7.0.1

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

RUN buildDeps='software-properties-common python-software-properties' && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends $buildDeps && \

    # install install dependancies
    apt-get install -y --no-install-recommends \
        ant \
        curl \
        libncurses5:i386 \
        libstdc++6:i386 \
        maven \
        wget \
        zlib1g:i386 \
    && \

    # install gradle
    cd /opt && \
    wget -O gradle.zip ${GRADLE_URL} && \
    unzip gradle.zip && rm gradle.zip && \
    ln -sf /opt/gradle-4.2/bin/gradle /usr/bin/gradle && \

    # use WebUpd8 PPA
    add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" -y && \
    apt-get update -y && \

    # automatically accept the Oracle license
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get install -y oracle-java8-set-default && \

    # install android sdk
    cd /opt && \
    mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip && \
    echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME && \

    # add cordova
    yarn global add cordova@${CORDOVA_VERSION} && \
    yes | cordova --help && \
    
    # clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get autoremove -y && apt-get clean


