# Base image with JDK 17 for building the application
FROM ubuntu:22.04 AS build

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install required build dependencies
RUN apt-get update && apt-get install -y \
    debhelper \
    devscripts \
    build-essential \
    ant \
    git \
    javahelp2 \
    default-jdk \
    default-jre-headless \
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
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Set up build environment
RUN export JAVA_HOME=${JAVA_HOME}

# Build the application
RUN ant -f linux/build.xml

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
COPY --from=build /app/linux/build/libs/*.jar app.jar

# Expose port if needed
EXPOSE 3200

# Set environment variables for running a desktop application
ENV DISPLAY=:0

# Run the application
CMD ["xvfb-run", "java", "-jar", "app.jar"]
