# node-deb

Debian packaging for Node.js projects written 100% in `bash`.

Simple.

## Installation
`npm install node-deb`

## Compatibility

This exists mostly as an internal tool for my company, so until there is an `0.2.0` release, there will not be any sort
of assurances of compatibility between releases. This includes command line flags, executables, and init scripts.

## Usage

```
$ node-deb --help
Usage: node-deb [opts] -- file1 file2 ...
Opts:
  --cat-template)
    Print the contents of a given template then exit
  -d | --description)
     The description of the Debian package (default: 'node_deb.description' then 'description' from package.json)
  -e | --executable-name)
    The name of the executable (default: 'node_deb.executable_name' from package.json then $package-name)
  -g | --group)
     The Unix group the process will run as (default: 'node_deb.group' from package.json then $user)
  -h | --help)
    Display this message and exit
  -i | --init)
    Init script type {auto, upstart, systemd, none}. 'auto' chooses upstart or systemd. 'none' makes no init script. (default: 'node_deb.init' from package.json then 'auto')
  --list-json-overrides)
    List all fields of the 'node_deb' object in 'package.json' that can be used as an override then exit
  --list-templates)
    Print a list of available templates then exit
  --list-template-variables)
    Print a list of variales available to templates then exit
  -m | --maintainer)
    The maintainer of the Debian package (default: 'node_deb.maintainer' then 'author' from package.json)
  -n | --package-name)
    The name of the Debian package (default: 'node_deb.package_name' then 'name' from package.json)
  --no-delete-temp)
    Do not delete temp directory used to build Debian package
  --no-md5sums)
    Do not calculate md5sums for DEBIAN directory
  --start-command)
    The start command to use (default: 'node_deb.start_command' then 'scripts.start' from package.json)
  --template-control)
    Override Debian control template (default: 'node_deb.templates.control' from package.json then built-in)
  --template-executable)
    Override executable template (default: 'node_deb.templates.executable' from package.json then built-in)
  --template-postinst)
    Override maintainer script postinst template (default: 'node_deb.templates.postinst' from package.json then built-in)
  --template-postrm)
    Override maintainer script postrm template (default: 'node_deb.templates.postrm' from package.json then built-in)
  --template-prerm)
    Override maintainer script prerm template (default: 'node_deb.templates.prem' from package.json then built-in)
  --template-systemd-service)
    Override systemd unit template (default: 'node_deb.templates.systemd_service' from package.json then built-in)
  --template-upstart-conf)
    Override upstart conf template (default: 'node_deb.templates.upstart_conf' from package.json then built-in)
  -u | --user)
    The Unix user the process will run as (default: 'node_deb.user' from package.json then $package-name)
  --verbose)
    Print addtional information while packaging
  -v | --version)
    The version of the Debian package (default: 'node_deb.version' then 'version' from package.json)
  --)
    Delimiter separating options from files and directories
```

## Configuration
You do not need to add anything to `package.json` as it uses sane defaults. However, if you don't like these, there are
two options for overrides: command line options, or the JSON object `node_deb` at the top level of your `package.json`.

By default, if any of the following files exist, the will be included in the Debian package: `package.json`,
`npm-shrinkwrap.json`, and `node_modules/`. To maintain some amount of compatibility between releases, if these files
are not included in the command line arguments, a warning is issued alerting the user that they were included anyway.

For example, here are some sample `node_deb` overrides. The full list can be found by running
`node-deb --list-json-overrides`.

```json
{
  "name": "some-app",
  ...
  "node_deb": {
    "init": "systemd",
    "version": "1.2.3-beta",
    "start_command": "/usr/bin/node foo.js"
  }
}
```

Command line options always override values found in the `node_deb` object, and values found in the `node_deb` object
always override the values found in the rest of `package.json`.

Examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

## Examples
#### Ex. 1
`package.json`:

```json
{
  "name": "some-app",
  "version": "1.2.3",
  "scripts": {
    "start": "/usr/bin/node app.js arg1 arg2 arg3"
  }
}
```

`cmd`: `node-deb -- app.js lib/ package.json`

You will get:
- A Debian package named `some-app_1.2.3_all.deb`
  - Containing the files `app.js` & `package.json` and the directory `lib`
  - Installed via
    - `apt-get install some-app`
    - `apt-get install some-app=1.2.3`

On install, you will get.
- An executable named `some-app`
  - That starts the app with the command `/usr/bin/node app.js arg1 arg2 arg3`
- An `upstart` init script installed to `/etc/init/some-app.conf`
- A `systemd` unit file installed to `/etc/systemd/system/some-app.service`
- A Unix user `some-app`
- A Unix group `some-app`

#### Ex. 2
`package.json`:

```json
{
  "name": "some-other-app",
  "version": "5.0.2",
  "scripts": {
    "start": "/usr/bin/node --harmony index.js"
  }
}
```

`cmd`: `node-deb -u foo -g bar -v 20150826 -- index.js lib/ package.json`

You will get:
- A Debian package named `some-other-app_20150826_all.deb`
  - Containing the files `index.js` & `package.json` and the directory `lib`
  - Installed via
    - `apt-get install some-other-app`
    - `apt-get install some-other-app=20150826`

On install, you will get.
- An executable named `some-other-app`
  - That starts the app with the command `/usr/bin/node --harmony index.js`
- An `upstart` init script installed to `/etc/init/some-other-app.conf`
- A `systemd` unit file installed to `/etc/systemd/system/some-other-app.service`
- A Unix user `foo`
- A Unix group `bar`

#### &c.
`node-deb` can Debian-package itself. Just run `./node-deb -- node-deb templates/ package.json`.

More complete examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

## Requirements
- `dpkg`
- `jq`

These are both available through `apt` and `brew`.

## Contributing
Please make all pull requests to the `develop` branch.
