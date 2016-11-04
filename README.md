# node-deb

Debian packaging for Node.js projects written 100% in `bash`.

Simple.

## Installation
`npm install node-deb`

or

`git clone ${url} && cd node-deb && npm run node-deb && sudo dpkg -i $(find . -maxdepth 1 -type f -name '*.deb' | tail -n 1)`

## Usage

A simple project can be packaged with the following command.

```bash
node-deb -- index.js lib/ node_modules package.json
```

This command will add all of the above files and directories to a Debian package as well as generate the scripts
necessary to install, uninstall, start, and stop your application. On installation, via `dpkg -i $your_package_name`,
dedicated Unix users and groups will be created and your distribution's default init system will start and monitor
the process.

You do not need to add anything to your `package.json` as it uses sane defaults. However, if you don't like these, there are
two options for overrides: command line options, or the JSON object `node_deb` at the top level of your `package.json`. A
full explanation of the different options can be found by running `node-deb --help`.

By default, if any of the following files exist, the will be included in the Debian package: `package.json`,
`npm-shrinkwrap.json`, and `node_modules/`. If these files
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
    "start": "node --harmony index.js"
  }
}
```

`cmd`: `node-deb -u foo -g bar -v 20150826 -- index.js lib/ package.json node_modules`

You will get:
- A Debian package named `some-other-app_20150826_all.deb`
  - Containing the files `index.js` & `package.json` and the directories `lib` & `node_modules`
  - Installed via
    - `apt-get install some-other-app`
    - `apt-get install some-other-app=20150826`

On install, you will get.
- An executable named `some-other-app`
  - That starts the app with the command `node --harmony index.js`
- An `upstart` init script installed to `/etc/init/some-other-app.conf`
- A `systemd` unit file installed to `/etc/systemd/system/some-other-app.service`
- A Unix user `foo`
- A Unix group `bar`

#### Ex. 3
`package.son`:

```json
{
  "name": "a-third-app",
  "version": "0.10.1",
  "scripts": {
    "start": "/usr/bin/env node app.js"
  }
  ...
  "node_deb": {
    "init": "none",
    "dependencies": "apparmor, tor",
    "user": "tor-ro",
    "group": "www-data",
    "templates": {
      "postinst": "my-teplates/my-postinst-template.txt"
    }
  }
}
```

`cmd`: `node-deb -- app.js lib/ node_modules package.json npm-shrinkwrap.json`

You will get:
- A Debian package named `a-third-app_0.10.1_all.deb`
  - Containing the files `index.js`, `package.json`, & `npm-shrinkwrap.json`  and the directories `lib` &
    `node_modules`
  - With additional dependencies on `apparmor` and `tor`
  - Installed via
    - `apt-get install a-third-app`
    - `apt-get install a-third-app=0.10.1`
  - With the `postinst` script rendered from the template `my-postinst-template.txt`

On install, you will get.
- An executable named `a-third-app`
  - That starts the app with the command `/usr/bin/env node app.js`
- No `upstart` or `systemd` scripts
- A Unix user `tor-ro`
- A Unix group `www-data`

Note: Removal via `apt-get purge` will attempt to remove the user and group defined in the Debian package.
This can have serious consequences if the user or group is shared by other applications!

#### &c.
`node-deb` can Debian-package itself. Just run `npm run node-deb`.

More complete examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

## Requirements
- `dpkg`
- `fakeroot`
- `jq`

These are all available through `apt` and `brew`.

## Contributing
Please make all pull requests to the `develop` branch.
