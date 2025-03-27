# Use Ubuntu 22.04 as base image
#FROM ubuntu:22.04
# Set noninteractive mode to avoid prompts during package installation
#ENV DEBIAN_FRONTEND=noninteractive
# Install required dependencies including OpenJDK 17 JDK
#RUN apt-get update && apt-get install -y \
#    openjdk-17-jdk libx11-6 libglib2.0-0 liblcms2-2 \
#    liblensfun1 libjpeg8 libraw20 libtiff5 xvfb \
#    wget curl unzip ca-certificates software-properties-common \
#    ant build-essential git javahelp2 \
#    libglib2.0-dev liblcms2-dev liblensfun-dev libjpeg-dev \
#    libraw-dev libtiff-dev libx11-dev libxml2-utils pkg-config rsync \
#    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Set Java environment variables
#ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
#ENV PATH="${JAVA_HOME}/bin:${PATH}"
# Verify Java installation
#RUN java -version && javac -version
# Ensure Java is properly configured
#RUN update-alternatives --install /usr/bin/java java ${JAVA_HOME}/bin/java 1 \
#    && update-alternatives --install /usr/bin/javac javac ${JAVA_HOME}/bin/javac 1 \
#    && update-alternatives --set java ${JAVA_HOME}/bin/java \
#    && update-alternatives --set javac ${JAVA_HOME}/bin/javac
# Set working directory
#WORKDIR /app
# Copy project files (modify this based on your project)
#COPY . /app
# Default command (modify based on your application)
#CMD ["java", "-jar", "your-app.jar"]
# Expose required port (if applicable)
#EXPOSE 3200
# Set display environment variable for GUI apps
#ENV DISPLAY=:0
# Run application in an interactive manner
#CMD ["xvfb-run", "java", "-jar", "app.jar"]
# Use a base image with Java and X11 support
FROM ubuntu:22.04

# Set the environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages (Java, X11, VNC, etc.)
RUN apt-get update && apt-get install -y \
    openjdk-17-jre \
    openjdk-17-jdk \
    libx11-6 \
    libglib2.0-0 \
    liblcms2-2 \
    liblensfun1 \
    libjpeg8 \
    libraw20 \
    libtiff5 \
    xvfb \
    x11vnc \
    fluxbox \
    wget \
    curl \
    unzip \
    ca-certificates \
    software-properties-common \
    git \
    libglib2.0-dev \
    liblcms2-dev \
    liblensfun-dev \
    libjpeg-dev \
    libraw-dev \
    libtiff-dev \
    libx11-dev \
    libxml2-utils \
    pkg-config \
    rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the repo (or alternatively, copy the start.sh from your local files)
RUN git clone https://github.com/yourusername/yourrepo.git /app

# Set the start script permissions
RUN chmod +x /app/start.sh

# Expose port for VNC
EXPOSE 3200

# Set the entry point to the start script
CMD ["/app/start.sh"]
