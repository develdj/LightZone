# Use Ubuntu 22.04 as base image
FROM ubuntu:22.04

# Set noninteractive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies including OpenJDK 17 JDK
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk libx11-6 libglib2.0-0 liblcms2-2 \
    liblensfun1 libjpeg8 libraw20 libtiff5 xvfb \
    wget curl unzip ca-certificates software-properties-common \
    ant build-essential git javahelp2 \
    libglib2.0-dev liblcms2-dev liblensfun-dev libjpeg-dev \
    libraw-dev libtiff-dev libx11-dev libxml2-utils pkg-config rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Verify Java installation
RUN java -version && javac -version

# Ensure Java is properly configured
RUN update-alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
    && update-alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1 \
    && update-alternatives --set java ${JAVA_HOME}/bin/java \
    && update-alternatives --set javac ${JAVA_HOME}/bin/javac

# Set working directory
WORKDIR /app

# Copy project files (modify this based on your project)
COPY . /app

# Default command (modify based on your application)
CMD ["java", "-jar", "your-app.jar"]

# Expose required port (if applicable)
EXPOSE 3200

# Set display environment variable for GUI apps
ENV DISPLAY=:0

# Run application in an interactive manner
CMD ["xvfb-run", "java", "-jar", "app.jar"]
