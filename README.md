# maintenance plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-maintenance)
[![Gem](https://img.shields.io/gem/v/fastlane-plugin-maintenance.svg?style=flat)](https://rubygems.org/gems/fastlane-plugin-maintenance)
[![Downloads](https://img.shields.io/gem/dt/fastlane-plugin-maintenance.svg?style=flat)](https://rubygems.org/gems/fastlane-plugin-maintenance)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/jdee/fastlane-plugin-maintenance/blob/master/LICENSE)
[![CircleCI](https://img.shields.io/circleci/project/github/jdee/fastlane-plugin-maintenance.svg)](https://circleci.com/gh/jdee/fastlane-plugin-maintenance)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-maintenance`, add it to your project by running:

```bash
fastlane add_plugin maintenance
```

## About maintenance

Maintenance actions for plugin repos.

### rake action

```bash
rake(task: :release)
```

```bash
rake(task: :default)
```

```bash
rake(task: :default, rakefile: "Rakefile")
```

General-purpose rake action to build tasks from a Rakefile.

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
.rubocop.yml with a TODO note. Can be run from the command line with no arguments.

## Fastfile.internal

Add [fastlane/Fastfile.internal](./fastlane/Fastfile.internal) to your repo's
`Fastfile` to add the following predefined lanes for plugin maintenance:

|lane|description|options|
|----|-----------|-------|
|release|Release plugin to RubyGems||
|install|Install plugin gem in $GEM_HOME|local:yes to install without network access|
|tests|Run all tests and RuboCop||
|run_rubocop|Rub RuboCop|correct:yes to auto-correct many offenses|
|rubocop_update|Update RuboCop to the latest version using the update_rubocop action||

```Ruby
import_from_git(
  path: "fastlane/Fastfile.internal",
  url: "https://github.com/jdee/fastlane-plugin-maintenance"
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
fastlane tests
```

To automatically fix many of the styling issues, use
```
fastlane run_rubocop correct:yes
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
