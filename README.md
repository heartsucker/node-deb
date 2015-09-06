# node-deb

Debian packaging for Node.js projects written 100% in `bash`.

Simple.

## Installation
`npm install node-deb`

## Compatibility

This exists mostly as an internal tool for my company, so until there is an `0.2.0` release, there will not be any sort of assurances of compatibility between releases. This includes command line flags, binaries, and init scripts.

## Usage

`node-deb [opts] -- file1 file2 ...`

For the full list of options, run `node-deb -h`.

## Configuration
You need to add the following to your `package.json`:

```json
{
  "name": "some-app",
  ...
  "node_deb": {
    "start_command": "/usr/bin/node app.js arg1 arg2"
  }
}
```

### Overrides
Command line options always override values found in the `node_deb` object in `package.json`, and values found in the `node_deb` object always override the values found in the rest of `package.json`.

Examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

## Examples
#### Ex. 1
`package.json`:

```json
{
  "name": "some-app",
  "version": "1.2.3",
  "node_deb": {
    "start_command": "/usr/bin/node app.js arg1 arg2 arg3"
  }
}
```

`cmd`: `node-deb -- app.js lib/`

You will get:
- A Debian package named `some-app_1.2.3_all.deb`
  - Containing the file `app.js` and the directory `lib`
  - Installed via
    - `apt-get install some-app`
    - `apt-get install some-app=1.2.3`

On install, you will get.
- An executable named `some-app`
- An `upstart` init script installed to `/etc/init/some-app.conf`
  - Script starts the app with the command `/usr/bin/node app.js arg1 arg2 arg3`
- A Unix user `some-app`
- A Unix group `some-app`

#### Ex. 2
`package.json`:

```json
{
  "name": "some-other-app",
  "version": "5.0.2",
  "node_deb": {
    "start_command": "/usr/bin/node --harmony index.js"
  }
}
```

`cmd`: `node-deb -u foo -g bar -v 20150826 -- index.js lib/ node_modules/`

You will get:
- A Debian package named `some-other-app_20150826_all.deb`
  - Containing the file `index.js` and the directories `lib` and `node_modules`
  - Installed via
    - `apt-get install some-other-app`
    - `apt-get install some-other-app=20150826`

On install, you will get.
- An executable named `some-other-app`
- An `upstart` init script installed to `/etc/init/some-other-app.conf`
  - Script starts the app with the command `/usr/bin/node --harmony index.js`
- A Unix user `foo`
- A Unix group `bar`

#### &c.
More complete examples can be found by looking at `test.sh` and the corresponding projects in the `test` directory.

## Requirements
- `dpkg`
- `jq`

These are both available through `apt` and `brew`.

## TODO
- Untested with symlinks
- Have defaults for command line args in the `node_deb` object in `package.json`
- Install via `brew`
