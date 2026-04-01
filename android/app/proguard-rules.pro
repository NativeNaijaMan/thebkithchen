# ============================================================================
# ProGuard / R8 rules for The Broken Kitchen
# ============================================================================

# ---------------------------------------------------------------------------
# Play Core — deferred components / dynamic feature modules
#
# Flutter's embedding references Play Core split-install classes for deferred
# components. If the app does not use deferred components and does not ship
# the Play Core library, R8 will fail on the missing classes. The rules
# below tell R8 to silently ignore them; the code paths are never reached
# at runtime.
# ---------------------------------------------------------------------------
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
