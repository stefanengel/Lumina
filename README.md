#  Lumina

Lumina is a macOS app for monitoring the status of your builds on the Bitrise platform. 
Your branches should follow the gitflow pattern but the specific names can be configured.

## Functionality

Lumina provides a window with the status of all your builds that can be used as a status board. It also provides a status bar icon that lists all your builds, so you do not loase any screen real estate.

Clicking on any build will open it in your browser.

## Configuration

Lumina assumes the default branch names from gitflow, but you can configure them. It is also possible to define a different update interval. Interval changes require Lumina to be restarted to take effect.

If you want to filter out builds with a specific character sequence within their branch name, add them to the ignore list. This will take effect at the next refresh.
