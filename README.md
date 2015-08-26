# node-deb

Debian packaging for Node.js projects.

Simple.

## Installation
`npm install node-deb`

## Usage

`node-deb [opts] [files/dirs]`

For the full list of options, do `node-deb` with no arguments.

## Configuration
You need to add the following to your `package.json`:

```json
{
  "name": "some-app",
  ...
  "node_deb": {
    "start_script": "/usr/bin/node app.js arg1 arg2"
  }
}
```

## Examples
### Ex. 1
`package.json`:

```json
{
  "name": "some-app",
  "version": "1.2.3",
  "node_deb": {
    "start_script": "/usr/bin/node app.js arg1 arg2 arg3"
  }
}
```

`cmd`: `node-deb app.js lib/`

You will get:
- A Debian package named `some-app_1.2.3_all.deb`
  - Containing the file `app.js` and the directory `lib`
  - Installed via
    - `apt-get install some-app`
    - `apt-get install some-app=1.2.3`

On install, you will get.
- A binary named `some-app`
- An `upstart` init script installed to `/etc/init/some-app.conf`
  - Script starts the app with the command `/usr/bin/node app.js arg1 arg2 arg3`
- A Unix user `some-app`
- A Unix group `some-app`

### Ex. 2
`package.json`:

```json
{
  "name": "some-other-app",
  "version": "5.0.2",
  "node_deb": {
    "start_script": "/usr/bin/node --harmony index.js"
  }
}
```

`cmd`: `node-deb -u foo -g bar -v 20150826 index.js lib/ node_modules/`

You will get:
- A Debian package named `some-other-app_20150826_all.deb`
  - Containing the file `index.js` and the directories `lib` and `node_modules`
  - Installed via
    - `apt-get install some-other-app`
    - `apt-get install some-other-app=20150826`

On install, you will get.
- A binary named `some-other-app`
- An `upstart` init script installed to `/etc/init/some-other-app.conf`
  - Script starts the app with the command `/usr/bin/node --harmony index.js`
- A Unix user `foo`
- A Unix group `bar`

## Requirements
- `dpkg`
- `jq`

These are both available through `apt` and `brew`.

## TODO
- Untested with symlinks
- Cygwin support
- Have defaults for command line args in the `node_deb` object in `package.json`
- Install via `brew`
