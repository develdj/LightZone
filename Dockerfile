# Install additional build dependencies
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

# Verify Java and Ant installation
RUN which java && java -version \
    && which ant && ant -version

# Build the application
RUN cd lightcrafts && ant -v -f build.xml

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
