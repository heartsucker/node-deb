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
node-deb -- index.js lib/
```

This command will add all of the above files and directories to a Debian package as well as generate the scripts
necessary to install, uninstall, start, and stop your application. On installation, via `dpkg -i $your_package_name`,
dedicated Unix users and groups will be created and your distribution's default init system will start and monitor
the process.

`node-deb` uses sane defaults, so the only thing you need to add to your `package.json` is the app/cli entrypoint.
However, if you don't like these, there are two options for overrides: command line options, or the JSON object
`node_deb` at the top level of your `package.json`. A full explanation of the different options can be found by
running `node-deb --help`.

By default, if any of the following files exist, they will be included in the Debian package: `package.json` and
`npm-shrinkwrap.json`.

For example, here are some sample `node_deb` overrides. The full list can be found by running
`node-deb --list-json-overrides`.

```json
{
  "name": "some-app",
  ...
  "node_deb": {
    "init": "systemd",
    "version": "1.2.3-beta",
    "entrypoints": {
      "daemon": "foo.js --config /etc/some-app/config.js"
    }
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
  "node_deb": {
    "entrypoints": {
      "daemon": "app.js arg1 arg2"
    }
  }
}
```

`cmd`: `node-deb -- app.js lib/`

You will get:
- A Debian package named `some-app_1.2.3_all.deb`
  - Containing the files `app.js` & `package.json` and the directory `lib`
  - Installed via
    - `apt-get install some-app`
    - `apt-get install some-app=1.2.3`

On install, you will get.
- An executable named `some-app`
  - That starts the app with the command `app.js arg1 arg2 arg3`
- An `upstart` init script installed to `/etc/init/some-app.conf`
- A `systemd` unit file installed to `/etc/systemd/system/some-app.service`
- A `sysv` int script installed to `/etc/init.d/some-app`
- A Unix user `some-app`
- A Unix group `some-app`

#### Ex. 2
`package.json`:

```json
{
  "name": "some-other-app",
  "version": "5.0.2",
  "node_deb": {
    "entrypoints": {
      "daemon": "index.js --daemon"
    }
  }
}
```

`cmd`: `node-deb -u foo -g bar -v 20150826 -- index.js lib/`

You will get:
- A Debian package named `some-other-app_20150826_all.deb`
  - Containing the files `index.js`, `package.json`, & `npm-shrinkwrap.json` and the directories `lib` &
    `node_modules`
  - Installed via
    - `apt-get install some-other-app`
    - `apt-get install some-other-app=20150826`

On install, you will get.
- An executable named `some-other-app`
  - That starts the app with the command `index.js --daemon`
- An `upstart` init script installed to `/etc/init/some-other-app.conf`
- A `systemd` unit file installed to `/etc/systemd/system/some-other-app.service`
- A `sysv` int script installed to `/etc/init.d/some-other-app`
- A Unix user `foo`
- A Unix group `bar`

#### Ex. 3
`package.son`:

```json
{
  "name": "a-third-app",
  "version": "0.10.1",
  "node_deb": {
    "init": "none",
    "dependencies": "apparmor, tor",
    "user": "tor-ro",
    "group": "www-data",
    "templates": {
      "postinst": "my-teplates/my-postinst-template.txt"
    },
    "entrypoints": {
      "cli": "app.js"
    }
  }
}
```

`cmd`: `node-deb -- app.js lib/`

You will get:
- A Debian package named `a-third-app_0.10.1_all.deb`
  - Containing the files `index.js`, `package.json`, & `npm-shrinkwrap.json` and the directories `lib` &
    `node_modules`
  - With additional dependencies on `apparmor` and `tor`
  - Installed via
    - `apt-get install a-third-app`
    - `apt-get install a-third-app=0.10.1`
  - With the `postinst` script rendered from the template `my-postinst-template.txt`

On install, you will get.
- An executable named `a-third-app`
  - That starts the app with the command `app.js`
- No `upstart`, `systemd`, or `sysv` scripts
- A Unix user `tor-ro`
- A Unix group `www-data`

Note: Removal via `apt-get purge` will attempt to remove the user and group defined in the Debian package.
This can have serious consequences if the user or group is shared by other applications!

#### &c.
`node-deb` can Debian-package itself. Just run `npm run node-deb`.

More complete examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

### Options

This section incldues addtional details about the more advanced functionality of `node-deb`

#### `--install-strategy`

The install strategy determines how dependencies in `node_modules` are included in the final Debian package.

- `auto`: This attempts to take a minimal subset of package from the `node_modules` director using
  `npm ls --prod`. If this is not possible, it falls back to the `copy` method. On install, if `node_modules` is
  present, it runs `npm rebuild --prod`. If `node_modules` is not present, it runs `npm install --prod`. If `npm`
  is not present, it issues a warning that dependencies may be missing and continues with the Debian package installation.
- `copy`: This runs a blind `cp -rf` on the `node_modules` directory and includes everything in the Debian package.
  No actions are taking during package installation.
- `npm-install`: This option does not include the `node_module` in the Debian package and runs
  `npm install --production` as part of the `postinst` maintainer script.

## Requirements
- `dpkg`
- `fakeroot`
- [`jq`](https://stedolan.github.io/jq/)

These are all available through `apt` and `brew`.

### Dev Requirements
Tests are run via `docker`. This is also available through `apt` and `brew`.

## Support

`node-deb` only officially supports the currently supported LTS versions of Debian and Ubuntu. This includes both
for building packages and deploying packages. At the time of this update, this translates to Debian Wheezy through
Stretch and Ubuntu Precise through Xenial. Care has been taken to ensure this packages correctly on macOS, and macOS
specific issues should still be reported.


## Contributing
Please make all pull requests to the `develop` branch.

Please make sure all pull requests pass the test suite locally.
