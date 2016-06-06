# CHANGELOG

#### unreleased
- Changed
  - `node-deb` no longer produces `jq` errors about missing `package.json` when run outside a project directory
- Added
  - Command line option `--start-command` to allow setting of the start command from the command line

#### 0.1.11 - 2016-04-21
- **BREAKING**
  - Reverting the change from `0.1.9` where `node-deb` did *not* include the `node_modules` directory. Now the default
  behavior is to include this directory and warn when it is not included on the command line.
- Added
  - Less tolerance for shell script failures both in `node-deb` itself and all templates
  - `postinst` template now runs `npm rebuild` to recompile platform specific binaries
    - This combined with the forced inclusion of `node_modules` and `npm-shrinkwrap.json` aims to make packages and
    builds as reproducible as possible.

#### 0.1.10 - 2016-03-09
- Changed
  - `postinst` now runs `npm install` with the `--production` option

#### 0.1.9 - 2016-03-08
- **BREAKING**
  - `node-deb` will no longer include the `node_modules` directory, but instead will run `npm install` during the
  `postinst` step in the install directory. Thus, if `package.json` exists, it will be auto included in the `.deb`.
- Added
  - Better script logging
  - `package.json` and `npm-shrinkwrap.json` are included by default, and warning messages are displayed if they aren't
  included
  - If `node_deb.start_command` is not present in `package.json`, default to using `scripts.start`

#### 0.1.8 - 2016-03-01
- Changed
  - Using MIT license over GPL license
  - Slightly faster copying of files
  - Slightly faster md5sum calculations
  - Support using `gmd5sum` for packages built on OSX (with `brew install gmd5sum`)

#### 0.1.7 - 2015-11-19
- Changed
  - Handling of template injection that includes shell redirects

#### 0.1.6 - 2015-10-31
- Added
  - Command line flag `--list-template-variables` so users can see which variables are injected into templates
  - Allow the selections of `systemd` and `upstart` to the `--init` flag

#### 0.1.5 - 2015-10-27
- **BREAKING**
  - Moved installed files to `/usr/share/$package_name/app/` instead of `/usr/share/$package_name/` to avoid name
  conflicts if a user has a directory in their project called `bin`
- Added
  - Command line option to list and print available templates
  - Command line options to override default templates: `--template-{control, executable, postinst, postrm, prerm,
    systemd-service, upstart-conf}`
- Changed
  - The executable's start command now defaults to `node_deb.start_command` in the `package.json`

#### 0.1.4 - 2015-10-26
- Added
  - Command line flags for:
    - `-d | --description`: Debian package description
    - `-e | --executable-name`: the name of the runnable file
    - `-h | --help`: print help/usage message
    - `-i | --init`: select init type (auto, none)
    - `-m | --maintainer`: Debian package maintainer
    - `-n | --package-name`: the named of the Debian package
    - `--no-md5sums`: disable creating of md5sums in Debian package
  - `systemd` init support
  - Ability to disable init (useful for command line tools)
  - Command line options for `test.sh` (dev only)
- Changed
  - Changed references from `binary` to `executable` (because that's what it actually is)
  - Command line flag `-N` is now named `--no-delete-temp`

#### 0.1.3 - 2015-08-31
- Added
  - Automatic removal of the `.deb` staging directory
  - Command line flag to prevent deletion of the `.deb` staging directory
  - Add md5sums for all files in the `.deb` directory to the `DEBIAN` directory in the package

#### 0.1.2 - 2015-08-28
- Added
  - Check to ensure all target files exist before building `.deb`
  - `test.sh` and `test/` for automated testing (dev only)
- Changed
  - Correct handling of paths with whitespace

#### 0.1.1 - 2015-08-26
- Added
  - Command line flag and `package.json` field for Debian package version

#### 0.1.0 - 2015-08-26
- Added
  - Simple command line flags
  - Simple modifiers for Debian package, extraced from `package.json`
  - Templates for: Debian control file, `preinst`, `postinst`, `prerm`, `binary`, and Upstart script
