# Base image with build tools
FROM ubuntu:22.04 AS build

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANT_HOME=/opt/ant
ENV PATH="${JAVA_HOME}/bin:${ANT_HOME}/bin:${PATH}"

# Install core dependencies and OpenJDK
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    software-properties-common \
    && add-apt-repository ppa:openjdk-r/ppa \
    && apt-get update \
    && apt-get install -y \
    openjdk-17-jdk \
    openjdk-17-jre

# Install Ant
RUN wget https://downloads.apache.org/ant/binaries/apache-ant-1.10.14-bin.tar.gz \
    && tar -xzf apache-ant-1.10.14-bin.tar.gz \
    && mv apache-ant-1.10.14 /opt/ant \
    && rm apache-ant-1.10.14-bin.tar.gz

# Install comprehensive build dependencies
RUN apt-get install -y \
    build-essential \
    git \
    javahelp2 \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Extensive debugging and verification
RUN echo "Java Version:" && java -version 2>&1 \
    && echo "Ant Version:" && ant -version 2>&1 \
    && echo "Java Home: $JAVA_HOME" \
    && echo "Ant Home: $ANT_HOME" \
    && echo "PATH: $PATH" \
    && ls -la /app/lightcrafts

# Attempt to build with extensive logging
RUN cd lightcrafts \
    && echo "Current directory contents:" \
    && ls -la \
    && echo "Attempting to build with verbose output..." \
    && ant -v -debug -f build.xml || (echo "Build failed. Collecting debug information..." \
    && cat build.log \
    && exit 1)

# Create runtime image
FROM ubuntu:22.04 AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jre \
    libx11-6 \
    libglib2.0-0 \
    liblcms2-2 \
    liblensfun1 \
    libjpeg8 \
    libraw20 \
    libtiff5 \
    xvfb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy built artifacts from build stage
COPY --from=build /app/lightcrafts/build/libs/*.jar app.jar

# Expose port if needed
EXPOSE 3200

# Set environment variables for running a desktop application
ENV DISPLAY=:0

# Run the application
CMD ["xvfb-run", "java", "-jar", "app.jar"]
