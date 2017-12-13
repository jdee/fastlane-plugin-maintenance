# maintenance plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-maintenance)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-maintenance`, add it to your project by running:

```bash
fastlane add_plugin maintenance
```

## About maintenance

Maintenance actions for plugin repos. May be run as standalone actions from the
command line. These actions take no parameters.

### rake action

```bash
rake task: :release
```

```bash
rake task: :default
```

```bash
rake task: :default, rakefile: "Rakefile"
```

Release your plugin to RubyGems using rake release.

|Parameter|Description|
|---------|-----------|
|task|The task to build. Symbol or String.|
|rakefile|The Rakefile to use. Defaults to "Rakefile"|
|options|Options for the task. Pass an array for multiple options.|

### update_rubocop action

```bash
update_rubocop
```

Updates rubocop to the latest version. Pins your gemspec to a new version of rubocop if
necessary. Runs rubocop -a to auto-correct many offenses. Adjusts TargetRubyVersion.
Automatically corrects namespace changes. Disables any remaining failing Cops in your
.rubocop.yml with a TODO note. Run from the command line with no arguments.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary)

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
