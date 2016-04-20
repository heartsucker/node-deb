# CHANGELOG

#### unreleased
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
