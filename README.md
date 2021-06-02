#  Lumina

Lumina is a macOS app for monitoring the status of your builds on the Bitrise platform. 
Your branches should follow the gitflow pattern but the specific names can be configured.

It can group parallel running builds for the same commit and features full support for christmas decorations during december.

![Lumina](LuminaDemo.gif)

## Functionality

Lumina provides a window with the status of all your builds that can be used as a status board. It also provides a status bar icon that lists all your builds, so you do not loose any screen real estate.

Clicking on any build will open it in your browser.

## Configuration

Lumina assumes the default branch names from gitflow, but you can configure them. It is also possible to define a different update interval. Interval changes require Lumina to be restarted to take effect.

To connect to Bitrise you have to provide the base url, your auth token and the slug of the app which builds you want to monitor. The base url might look like this: ```https://api.bitrise.io/v0.1/apps```.

If you want to filter out builds with a specific character sequence within their branch name, add them to the ignore list. This will take effect at the next refresh.

## TODO

### Build queue status

- Get organizations:
https://api.bitrise.io/v0.1/organizations

```
{
  "data": [
    {
      "name": "dmTECH",
      "slug": "c1b0c43e6f46c876",
      "avatar_icon_url": "https://concrete-userfiles-production.s3.us-west-2.amazonaws.com/organizations/c1b0c43e6f46c876/avatar/avatar.png",
      "concurrency_count": 10,
      "owners": [
        {
          "slug": "ea7aca815ae5dac7",
          "username": "stefan.engel",
          "email": "Stefan.Engel@dm.de"
        },
        {
          "slug": "c1d6fa663da7fd4e",
          "username": "christophwendt",
          "email": "Christoph.Wendt@dm.de"
        }
      ]
    }
  ]
}
```

- Get number of queue slots for organization:
https://api.bitrise.io/v0.1/organizations/c1b0c43e6f46c876

```
{
  "data": {
    "name": "dmTECH",
    "slug": "c1b0c43e6f46c876",
    "avatar_icon_url": "https://concrete-userfiles-production.s3.us-west-2.amazonaws.com/organizations/c1b0c43e6f46c876/avatar/avatar.png",
    "concurrency_count": 10,
```

- Get number of running builds:
https://api.bitrise.io/v0.1/builds?owner_slug=c1b0c43e6f46c876&is_on_hold=false&status=0

- Get number of waiting builds:
https://api.bitrise.io/v0.1/builds?owner_slug=c1b0c43e6f46c876&is_on_hold=true&status=0
