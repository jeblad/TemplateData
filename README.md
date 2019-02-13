# TemplateData

Fork of Extension:TemplateData for Mediawiki. This version has additional code for accessing TemplateData as Lua tables.

This version is unsupported and could be replaced by functionality in the standard [Extension:TemplateData](https://mediawiki.org/wiki/Extension:TemplateData) or could even inevitably fail due to lack of maintenance.

Please verify that the remaining code is up to date.

## Install

This version of the extension can not be installed by the usual tools. In particular, it can not be inserted by calling `vagrant roles enable templatedata`. One option could be to add it manually, which is pretty straight forward. Another option could be to first install the usual version by using vagrant roles, and then replace the repo with this one.

For an ordinary install, download and place the file(s) in a directory called TemplateData in your extensions/ folder. Preferably by doing a

```bash
$ git clone --recursive git@github.com:jeblad/TemplateData.git .
```

Then add the following code at the bottom of your LocalSettings.php

```php
wfLoadExtension( 'TemplateData' );
```
## Documentation

There are a separate generated [TemplateData references](https://jeblad.github.io/TemplateData/) for the [source docs](docs/). The generated docs are made by [LDoc](https://stevedonovan.github.io/ldoc/manual/doc.md.html).

Individual parts will be documented in the [wiki](https://github.com/jeblad/TemplateData/wiki) at Github, with a local repo placed in the [docs](./docs) subfolder.
