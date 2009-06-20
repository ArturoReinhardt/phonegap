# PhoneGap

### iPhone

In order to customize a build of PhoneGap to your own application, make sure you change the
name of your application in the Info.plist file.  This will ensure that all class references
in your application's JavaScript file will be expanded to match your application's name.

The script iphone/build-phonegap.sh is configured to be run automatically at build-time.  This
will build the javascript for your app, and will copy it into the build directory of your
project.  This means, the only javascript you need to include in your index.html is "app.js".
