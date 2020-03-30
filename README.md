# The Stay Home Challenge

This is a [flutter](https://flutter.dev/) project.

## Add secret tokens

See `secrets.dart.example` and `secrets.xml.example` inside the `./lib` directory.

Create `./android/key.properties` according to these [instructions](https://flutter.dev/docs/deployment/android#reference-the-keystore-from-the-app).

## Run debug

```
flutter run
```

## Release version to stores

* Version bump by changing `./pubspec.yaml`

* Test the version on iOS and Android emulators with `flutter run -d all`

### iOS

* Run `open ios/Runner.xcworkspace`

* Make sure `Build for generic iOS device` is selected

* `Product` > `Archive`

* In the `Archives` window that opens, select the archive and `Distribute App` > `App Store Connect` > `Upload`

### Android

* Run `flutter build appbundle`

* To test manually:

  * `brew install bundletool`
  
  * Extract APK with `bundletool build-apks --bundle=./app-release.aab --output=./app-release.apks --mode=universal`

  * Rename `./app-release.apks` to `./app-release.zip` and extract