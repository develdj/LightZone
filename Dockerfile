# Base image with JDK 17 for building the application
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Install necessary build dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    wget \
    && apt-get clean

# Create Gradle wrapper directories
RUN mkdir -p /app/gradle/wrapper

# Download Gradle wrapper if not present
RUN wget -O /app/gradlew https://raw.githubusercontent.com/gradle/gradle/v7.6.0/gradlew && \
    chmod +x /app/gradlew

# Use the full download URL for Gradle distribution
RUN wget -O /app/gradle/wrapper/gradle-wrapper.jar https://downloads.gradle.org/distributions/gradle-7.6-bin.jar

RUN echo "distributionUrl=https://downloads.gradle.org/distributions/gradle-7.6-bin.zip" > /app/gradle/wrapper/gradle-wrapper.properties

# Copy entire project
COPY . /app

# Create Gradle wrapper script if it doesn't exist
RUN if [ ! -f /app/gradlew ]; then \
    wget -O /app/gradlew https://raw.githubusercontent.com/gradle/gradle/v7.6.0/gradlew && \
    chmod +x /app/gradlew; \
    fi

# Verify Gradle wrapper
RUN /app/gradlew --version

# Build the Linux version of the application using Gradle wrapper
RUN /app/gradlew build -p linux --no-daemon --stacktrace

# Use a minimal image to run the application with graphical support
FROM ubuntu:22.04 AS runtime

# Install dependencies for running a GUI app and image handling
RUN apt-get update && apt-get install -y \
    libx11-dev \
    libxcomposite-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libgl1-mesa-glx \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libjpeg-dev \
    libraw-dev \
    libsdl2-2.0-0 \
    xvfb \
    openjdk-17-jre \
    && apt-get clean

# Set working directory
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/linux/build/libs/*.jar app.jar

# Expose port 3200 (if your app uses this for communication)
EXPOSE 3200

# Set environment variables for running a desktop application (X11)
ENV DISPLAY=:0

# Run the application as a desktop app (assuming it launches a GUI)
CMD ["xvfb-run", "java", "-jar", "app.jar"]
