FROM eclipse-temurin:17-jdk AS build

WORKDIR /app

# Copy necessary Gradle files for caching
COPY gradlew settings.gradle.kts build.gradle.kts /app/
COPY gradle/ /app/gradle/

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Copy the entire project
COPY . .

# Build the application
RUN ./gradlew build --no-daemon

# Use a smaller base image for running the app
FROM eclipse-temurin:17-jre AS runtime

WORKDIR /app

# Copy the built application from the build stage
COPY --from=build /app/build/libs/*.jar /app/app.jar

# Expose the application port (modify if necessary)
EXPOSE 3200

# Run the application
CMD ["java", "-jar", "/app/app.jar"]
