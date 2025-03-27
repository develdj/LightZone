# Base image with build tools
FROM ubuntu:22.04 AS build

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANT_HOME=/opt/ant
ENV PATH="${JAVA_HOME}/bin:${ANT_HOME}/bin:/usr/local/bin:${PATH}"

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget curl unzip ca-certificates software-properties-common \
    openjdk-17-jdk ant build-essential git javahelp2 \
    libglib2.0-dev liblcms2-dev liblensfun-dev libjpeg-dev \
    libraw-dev libtiff-dev libx11-dev libxml2-utils pkg-config rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure Java is properly configured
RUN update-alternatives --set java ${JAVA_HOME}/bin/java \
    && update-alternatives --set javac ${JAVA_HOME}/bin/javac

# Verify Java & Ant
RUN echo "Java & Ant Verification" \
    && echo "JAVA_HOME is set to: $JAVA_HOME" \
    && ls -l $JAVA_HOME/bin/java \
    && java -version && javac -version \
    && export JAVA_HOME=${JAVA_HOME} && ant -version

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Build application
RUN cd lightcrafts && ant -f build.xml -v

# Runtime image
FROM ubuntu:22.04 AS runtime

# Install only required runtime dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jre libx11-6 libglib2.0-0 liblcms2-2 \
    liblensfun1 libjpeg8 libraw20 libtiff5 xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy built artifacts
COPY --from=build /app/lightcrafts/build/libs/*.jar app.jar

# Expose required port (if applicable)
EXPOSE 3200

# Set display environment variable for GUI apps
ENV DISPLAY=:0

# Run application in an interactive manner
CMD ["xvfb-run", "java", "-jar", "app.jar"]
