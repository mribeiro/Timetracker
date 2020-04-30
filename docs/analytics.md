# App analytics

## Purpose

The purpose of analytics in the app is understanding how it is most used and pave way for improvements. Knowing if a certain error is showing too often or users are accessing a certain screen very often will help directing focus-

## Platform

Timetracker analytics are provided by Microsoft AppCenter.

## Data gathered

No personal data is gathered. The only information gathered concerns user's generic info like the macOS version the Mac is running or the macOS language.
Apart from that, the following information is gathered.


| Event         |Data sent|    Purpose   |      When    |
|---------------|---------|--------------|--------------|
|window-opened  | Name of the window opened | Know what are the most used windows | When a window is opened|
|task-started   | The entry point| Understand from where the tasks are more often started| When a task is explicitly started|
|task-stopped   | The entry point | Understand from where the tasks are more often stopped | When a task is explicitly stopped|
|builder-changed| The new builder picked | Get to know what are the most famous builders | When the builder is changed|
|dock-icon-changed| Status of the icon (showing or not)|Know if the users are mostly hiding the dock icon| When the icon is shown/hidden|
|logs-changed| Status of logs (enabled or disabled)|Know if the user often (des)activate logs| When the logs option is (de)activated|
|error-shown| The reason of the error | Know if the errors are seeing often and know what UI/UX needs improvements|When an error is shown
|analytics-changed| Status of analytics | Know if users are (de)activating analytics often|When the analytics option is (de)activated

## Opt-out

You can easily opt-out from the analytics. This can be done in Preferences -> Misc and tick "Disable analytics". The gathering of analytics is switched off immediately and the preference is kept until manually changed.