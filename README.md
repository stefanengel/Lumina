#  Lumina

Lumina is a macOS app for monitoring the status of your builds on the Bitrise platform. 
Your branches should follow the gitflow pattern but the specific names can be configured.

It can group parallel running builds for the same commit and features full support for christmas decorations during december.

![Lumina](LuminaDemo.gif)

## Functionality

Lumina provides a window with the status of all your builds that can be used as a status board. It also provides a status bar icon that lists all your builds, so you do not loose any screen real estate.

Clicking on any build will open it in your browser.

## Configuration

### Settings

Lumina assumes the default branch names from gitflow, but you can configure them. It is also possible to define a different update interval. Interval changes require Lumina to be restarted to take effect.

If you want to filter out builds with a specific character sequence within their branch name, add them to the ignore list. This will take effect at the next refresh.

### Provider

For now, Bitrise is the only provider supported by Lumina.

To connect to Bitrise you have to provide the base url, your auth token and the slug of the app which builds you want to monitor. The base url might look like this: ```https://api.bitrise.io/v0.1/apps```.

The auth token can be obtained by logging into Bitrise, where you can create one in the security settings.

The app slug can be obtained from the url when you log into bitrise and click on the app that you want to monitor: https://app.bitrise.io/app/HERE_IS_YOUR_APPS_BUILD_SLUG#/builds.

If you enable "Group triggered builds by parent build number", Lumina will scan each builds environment variables for a ```SOURCE_BITRISE_BUILD_NUMBER```. If it finds one, the build will be grouped with other builds that have the same ```SOURCE_BITRISE_BUILD_NUMBER``` and with the source build that hat the corresponding build number. The grouped builds will appear by the name of the workflow that they are running.

You can configure the workflows that you are interested in. If the list is empty, only builds running on the ```primary``` workflow will be considered.
