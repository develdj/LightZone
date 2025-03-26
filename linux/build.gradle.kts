plugins {
    kotlin("jvm")
    application
    java
}

dependencies {
    implementation(project(":lightcrafts"))
    implementation("javax.help:javahelp:2.0.05")
    
    // Add potential test and compile dependencies
    testImplementation("junit:junit:4.13.2")
    implementation(kotlin("stdlib-jdk8"))
}

application {
    mainClass.set("com.lightcrafts.platform.linux.LinuxLauncher")
}

// Add some standard Java conventions
java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = "17"
    }
}
