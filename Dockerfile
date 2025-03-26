# Base image with JDK 17 for building the application
FROM eclipse-temurin:17-jdk AS build

WORKDIR /app

# Copy necessary Gradle files for building (including those under linux directory)
COPY gradlew settings.gradle.kts linux/build.gradle.kts /app/

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Copy the source code from the linux directory
COPY linux/ /app/linux/

# Build the Linux version of the application
RUN ./gradlew build -p linux --no-daemon

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
    && apt-get clean

# Set working directory
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/linux/build/libs/*.jar app.jar

# Expose port 3200 (if your app uses this for communication)
EXPOSE 3200

# Set environment variables for running a desktop application (X11)
ENV DISPLAY=:0

# Run the application as a desktop app (assuming
