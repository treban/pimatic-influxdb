pimatic-manager
=======================

[![build status](https://img.shields.io/travis/treban/pimatic-influxdb.svg?branch=master?style=flat-square)](https://travis-ci.org/treban/pimatic-influxdb)
[![version](https://img.shields.io/npm/v/pimatic-influxdb.svg?branch=master?style=flat-square)](https://www.npmjs.com/package/pimatic-influxdb)
[![downloads](https://img.shields.io/npm/v/pimatic-influxdb.svg?branch=master?style=flat-square)](https://www.npmjs.com/package/pimatic-influxdb)
[![license](https://img.shields.io/github/license/treban/pimatic-influxdb.svg)](https://github.com/treban/pimatic-influxdb)

This plugin provides a influx db interface for [pimatic](https://pimatic.org/).

Please make feature requests!

#### Features
* save number attributes for all devices to influx db
* query the influxdb to get values

### Installation

Just activate the plugin in your pimatic config. The plugin manager automatically installs the package with his dependencys.

**HINT: The Plugin must be the first Plugin in the plugin section of the config.json.**
**Otherwise you'll get errors and you can't enable the influx extension of all devices via the GUI.**


### Configuration

You can load the plugin by adding following in the config.json from your pimatic server:

```
{
  "debug": true,
  "ip": "127.0.0.1",
  "plugin": "influxdb",
  "active": true
}
```

## CHANGELOG
[-> see CHANGELOG](https://github.com/treban/pimatic-influxdb/blob/master/CHANGELOG.md)
