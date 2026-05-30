# Mapbox iOS Setup

The Mapbox Maps SDK for iOS is downloaded via CocoaPods, which authenticates
using `~/.netrc` on macOS. This must be configured once per machine before
running `pod install` or `flutter pub get`.

Add the following to `~/.netrc` (create the file if it doesn't exist):

```
machine api.mapbox.com
  login mapbox
  password YOUR_MAPBOX_SECRET_TOKEN
```

Then lock down the file permissions (required by netrc):

```sh
chmod 600 ~/.netrc
```

After that, a normal `flutter pub get` or `cd ios && pod install` will work.
