allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Plugin subprojects ask for SDK components that are not installed here
// (NDK 28.x, platform android-35) and the machine cannot auto-download
// them — pin every module to the locally installed NDK and compileSdk.
// Registered before the evaluationDependsOn(":app") block so no project
// has been evaluated yet; the state guard covers any that already were.
subprojects {
    fun forceAndroidConfig() {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
            ?.apply {
                ndkVersion = "27.1.12297006"
                compileSdkVersion(36)
            }
    }
    if (state.executed) forceAndroidConfig() else afterEvaluate { forceAndroidConfig() }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
