#  Lumina

Lumina is a macOS app for monitoring the status of your builds on the Bitrise platform. 
Your branches should follow the gitflow pattern but the specific names can be configured.

![Lumina](LuminaDemo.gif)

## Functionality

Lumina provides a window with the status of all your builds that can be used as a status board. It also provides a status bar icon that lists all your builds, so you do not loose any screen real estate.

Clicking on any build will open it in your browser.

## Configuration

Lumina assumes the default branch names from gitflow, but you can configure them. It is also possible to define a different update interval. Interval changes require Lumina to be restarted to take effect.

To connect to Bitrise you have to provide the base url, your auth token and the slug of the app which builds you want to monitor. The base url might look like this: ```https://api.bitrise.io/v0.1/apps```.

If you want to filter out builds with a specific character sequence within their branch name, add them to the ignore list. This will take effect at the next refresh.
