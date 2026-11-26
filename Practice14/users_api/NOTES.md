# Practice 14 notes

## Level 1 - identity and version

applicationId and namespace: kz.ramazan.users (was com.example.users_api).
minSdk / targetSdk / versionCode / versionName come from flutter.* in build.gradle.kts.

version: 1.0.1+2
- 1.0.1 is versionName: for people, shown in the store and in About. Changes when we want (1.0.0 -> 1.0.1).
- 2 is versionCode (build number): for the store, a plain integer. It must go up on every upload, the store refuses the same or a lower one.

If versionCode = 1 is hard-coded in Gradle, bumping pubspec to +3 changes nothing: the build number stays 1, so the store rejects the upload.

## Level 2 - the key

.gitignore got *.jks, *.keystore, android/key.properties, env/*.local.json in a commit before the key existed.
The key is ~/upload-keystore.jks, outside the project, alias upload. Backup: ~/Documents/upload-keystore-backup.jks

keytool -printcert -jarfile build/app/outputs/flutter-apk/app-arm64-v8a-release.apk:
```
Not a signed jar file
```
keytool only reads the old v1 (JAR) signature. This APK has only the v2 signature (minSdk is 24+), so I checked it with apksigner:

apksigner verify --print-certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk:
```
Verified using v1 scheme (JAR signing): false
Verified using v2 scheme (APK Signature Scheme v2): true
Signer #1 certificate DN: CN=Ramazan Tanirbergen, OU=Students, O=KBTU, L=Almaty, C=KZ
Signer #1 certificate SHA-256 digest: 8d796e03d595fb666aac7d40067dfea442910db524cff429832b1ca4fdfb5fed
```

keytool -list -v -keystore ~/upload-keystore.jks (the same certificate, the SHA-256 matches):
```
Alias name: upload
Owner: CN=Ramazan Tanirbergen, OU=Students, O=KBTU, L=Almaty, C=KZ
Issuer: CN=Ramazan Tanirbergen, OU=Students, O=KBTU, L=Almaty, C=KZ
Valid from: Thu Nov 26 14:44:21 GMT+05:00 2026 until: Mon Apr 13 14:44:21 GMT+05:00 2054
SHA256: 8D:79:6E:03:D5:95:FB:66:6A:AC:7D:40:06:7D:FE:A4:42:91:0D:B5:24:CF:F4:29:83:2B:1C:A4:FD:FB:5F:ED
```
It is my key, not "Android Debug".

If I had committed the key and key.properties, a classmate could build an app with my applicationId, sign it with my key, and it would install as an update over mine.
With Play App Signing, Google keeps the real app signing key and my key is only an upload key: if it leaks, I ask Google to reset the upload key and the app is still safe.

Scrub a file from git history:
git filter-repo --invert-paths --path android/key.properties
git push --force --all
(and still treat the key as leaked: make a new one)

## Level 3 - environments

lib/core/env.dart is the only file with fromEnvironment.
USE_FAKES=true -> FakeUserRepository, two users, no network.
ENV=staging, API_HOST=example.invalid -> About shows both values, and the list shows the Offline view because that host does not exist.

The developer host switch can not be done with fromEnvironment: those values are const, baked in at build time, the app can not change them while it runs.
So the switch saves the host in shared_preferences and main.dart reads it on the next start.
It is only behind kDebugMode: in a release build a user must not be able to send the app to another server.

## Level 4 - icon, splash, name

Own icon (indigo with two people), adaptive icon foreground, splash and Android 12 splash, made with flutter_launcher_icons and flutter_native_splash.
App name "Users" in AndroidManifest.xml and Info.plist.
INTERNET is in the main AndroidManifest.xml. Without it the release build shows the Offline view forever (the debug manifest has it, the release one does not).

## Level 5 - the release

app-arm64-v8a-release.apk: 17M, debug APK: 155M (ls -lh build/app/outputs/flutter-apk/).
app-release.aab: 52.5MB.
Installed from the APK file on the Android emulator (sdk gphone64 arm64), not on a real phone.

With --split-per-abi Flutter adds 1000 * ABI number to versionCode, so the first arm64 APK showed "1.0.1 (2002)" in About.
I built it again with -P force-version-code-ignoring-abi=true, now About shows "1.0.1 (2)".

Without symbols an obfuscated crash log has no file names and no line numbers, only addresses like `#00 abs 0000007a1b2c3d4e virt ...`.
flutter symbolize -i crash.txt -d releases/1.0.1+2/symbols/app.android-arm64.symbols turns it back into file names and lines.

The .aab is for the store, it can not be installed on a phone directly.
