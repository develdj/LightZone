# First stage: Build the application
FROM eclipse-temurin:17-jdk-alpine AS build

# Set working directory
WORKDIR /app

# Copy only necessary Gradle files first for better caching
COPY gradlew gradlew.bat settings.gradle.kts build.gradle.kts /app/
COPY gradle /app/gradle

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Download dependencies before copying source code (improves caching)
RUN ./gradlew dependencies --no-daemon || true

# Copy the entire project
COPY . /app

# Build the project
RUN ./gradlew build --no-daemon

# Second stage: Create a minimal runtime image
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the compiled JAR from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Run the application
CMD ["java", "-jar", "app.jar"]
