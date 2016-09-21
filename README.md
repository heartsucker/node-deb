# node-deb

Debian packaging for Node.js projects written 100% in `bash`.

Simple.

## Installation
`npm install node-deb`

or

`git clone ${url} && cd node-deb && npm run node-deb && sudo dpkg -i $(find . -maxdepth 1 -type f -name '*.deb' | tail -n 1)`

## Usage

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

#### &c.
`node-deb` can Debian-package itself. Just run `./node-deb -- node-deb templates/ package.json`.

More complete examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

## Requirements
- `dpkg`
- `fakeroot`
- `jq`

These are all available through `apt` and `brew`.

## Contributing
Please make all pull requests to the `develop` branch.
