# Practice 14 notes

## Level 1 - identity and version

applicationId and namespace: kz.ramazan.users (was com.example.users_api).
minSdk / targetSdk / versionCode / versionName come from flutter.* in build.gradle.kts.

version: 1.0.1+2
- 1.0.1 is versionName: for people, shown in the store and in About. Changes when we want (1.0.0 -> 1.0.1).
- 2 is versionCode (build number): for the store, a plain integer. It must go up on every upload, the store refuses the same or a lower one.

With versionCode = 1 hard-coded in Gradle and pubspec at +3, About still showed (1). That is how the third upload gets rejected.

## Level 2 - the key

.gitignore got *.jks, *.keystore, android/key.properties, env/*.local.json in a commit before the key existed.
The key is ~/upload-keystore.jks, outside the project, alias upload. Backup: (where you put the copy, not the password)

keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk:
(paste the output here after the release build)

If I had committed the key and key.properties, a classmate could build an app with my applicationId, sign it with my key, and it would install as an update over mine.
With Play App Signing, Google keeps the real app signing key and my key is only an upload key: if it leaks, I ask Google to reset the upload key and the app is still safe.

Scrub a file from git history:
git filter-repo --invert-paths --path android/key.properties
git push --force --all
(and still treat the key as leaked: make a new one)

## Level 3 - environments

lib/core/env.dart is the only file with fromEnvironment.
USE_FAKES=true -> FakeUserRepository, two users, no network.
ENV=staging, API_HOST=example.invalid -> About shows both, the list shows the Offline view.

The developer host switch can not be done with fromEnvironment: those values are const, baked in at build time, the app can not change them while it runs.
So the switch saves the host in shared_preferences and main.dart reads it on the next start.
It is only behind kDebugMode: in a release build a user must not be able to send the app to another server.

## Level 4 - icon, splash, name

Own icon (indigo with two people), adaptive icon foreground, splash and Android 12 splash, made with flutter_launcher_icons and flutter_native_splash.
App name "Users" in AndroidManifest.xml and Info.plist.
INTERNET is in the main AndroidManifest.xml. Without it the release build shows the Offline view forever (the debug manifest has it, the release one does not).

## Level 5 - the release

app-arm64-v8a-release.apk: (size) MB, debug APK: (size) MB

Without symbols an obfuscated crash log has no file names and no line numbers, only addresses like `#00 abs 0000007a1b2c3d4e virt ...`.
flutter symbolize -i crash.txt -d releases/1.0.1+2/symbols/app.android-arm64.symbols turns it back into file names and lines.

The .aab is for the store, it can not be installed on a phone directly.
