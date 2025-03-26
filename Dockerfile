# Use Eclipse Temurin JDK 17 for building
FROM eclipse-temurin:17-jdk AS build

WORKDIR /app

# Copy only necessary Gradle files first for better caching
COPY gradlew settings.gradle.kts build.gradle.kts /app/
COPY gradle/ /app/gradle/

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Copy the rest of the application source code
COPY src/ /app/src/

# Build the application
RUN ./gradlew build --no-daemon

# Use Eclipse Temurin JRE 17 for running
FROM eclipse-temurin:17-jre AS runtime

WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose port 3200
EXPOSE 3200

# Run the application
CMD ["java", "-jar", "app.jar"]
