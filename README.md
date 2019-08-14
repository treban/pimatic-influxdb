pimatic-manager
=======================

[![build status](https://img.shields.io/travis/treban/pimatic-influxdb.svg?branch=master?style=flat-square)](https://travis-ci.org/treban/pimatic-influxdb)
[![version](https://img.shields.io/npm/v/pimatic-influxdb.svg?branch=master?style=flat-square)](https://www.npmjs.com/package/pimatic-influxdb)
[![downloads](https://img.shields.io/npm/v/pimatic-influxdb.svg?branch=master?style=flat-square)](https://www.npmjs.com/package/pimatic-influxdb)
[![license](https://img.shields.io/github/license/treban/pimatic-influxdb.svg)](https://github.com/treban/pimatic-influxdb)

This plugin provides a influx db interface for [pimatic](https://pimatic.org/).

* The plugin is still alpha. It works, but there is no warranty for production systems! *

Please make feature requests!

#### Features
* save numeric attributes for all devices to influx db
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

## Usages

The plugin provides two functions.

### VariablesDevice to query the influx db

The new *InfluxVariable* device is like the normal Variable device.
You can define a query and a database to get values from the InfluxDB.

example:
```
{
  "variables": [
    {
      "name": "powermeter",
      "query": "SELECT last(\"value\") FROM \"vzlogger\" WHERE (\"uuid\" = '370d0520-cbfc-11e7-a3b1-39b3e41796be')",
      "database": "vzlogger",
      "unit": "kWh",
      "label": "powermeter"
    }
  ],
  "xAttributeOptions": [],
  "id": "influx-variable",
  "name": "influx-variable",
  "class": "InfluxVariable"
}
```
Currently, the device expects only one value with *last* function inside the query.

### Push attribute to influx db

You can add to each pimatic device a config extension like this.
If the influxdb plugin is the first plugin, you can activate the extensions over the GUI.

```
"influx": {
  "active": true
}
```
Now the plugin push all numeric attributes automatically to influxdb.

The database is pimatic and will be created at first start.

The measurement is "attribute". The fields are the different attributes names.
Each entry is taged by the device.id.

The schema looks like this:

schema: [
  {
    measurement: 'attributes',
    fields: {
      temperature
      humidity
      ...
    },
    tags: [
      'device'
    ]
  }
]

## CHANGELOG
[-> see CHANGELOG](https://github.com/treban/pimatic-influxdb/blob/master/CHANGELOG.md)
