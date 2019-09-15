module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = require('lodash')

  InfluxConnection = require('./influx-connector')(env)

  class Influxdbplugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      @ip = @config.ip
      @port = @config.port

      @ready=false

      @connect()

      @dev_map={}

      deviceClasses = [
        InfluxVariable
      ]
      deviceConfigDef = require("./device-config-schema.coffee")
      for DeviceClass in deviceClasses
        do (DeviceClass) =>
          @framework.deviceManager.registerDeviceClass(DeviceClass.name, {
            configDef: deviceConfigDef[DeviceClass.name],
            createCallback: (deviceConfig, lastState) => new DeviceClass(deviceConfig, lastState, @framework, this)
          })

      @framework.deviceManager.deviceConfigExtensions.push(new InfluxConfigExtension())

      @framework.on 'deviceAdded', (device) =>
        if device.config.influx?.active
          @dev_map[device.id]={
            device: device
          }
          for attr of device.attributes
            if device.attributes[attr].type is "number"
              do (attr) =>
                device.on attr, (val) =>
                  if val?
                    env.logger.debug device.name + " write " + attr + " with "+ val
                    field = {}
                    field[attr]=val
                  #  if @ready
                    @Connector.writeMeasurement({device: device.id},field).then( (result) =>
                      env.logger.debug "ok"
                    ).catch( (err) =>
                      env.logger.error err.message
                    )

      if @config.interval > 0
        @reconnect = setInterval =>
          if @ready
            for dev of @dev_map
              for attr of @dev_map[dev].device.attributes
                if @dev_map[dev].device.attributes[attr].type is "number"
                  if @dev_map[dev].device._attributesMeta[attr].value?
                #    env.logger.debug "send"
                    field = {}
                    field[attr]=@dev_map[dev].device._attributesMeta[attr].value
                    @Connector.writeMeasurement({device: @dev_map[dev].device.id},field)
                    .catch( (err) =>
                      env.logger.error err.message
                    )
        ,@config.interval*1000

      @framework.deviceManager.on 'discover', (eventData) =>
        @framework.deviceManager.discoverMessage 'pimatic-influx', "scan for databases ..."
        @Connector.getDatabaseNames().then( (dbase) =>
          for db in dbase
            do (db) =>
              @Connector.getMeasurements(db).then( (names) =>
                for nam in names
                  do (nam) =>
                    env.logger.debug db + " - " + nam
                  #  @Connector.getSeries(nam,db).then( (keys) =>
                  #    env.logger.error keys
                  #    @Connector.query('SELECT LAST('+keys') FROM "'+nam+'"', db).then( (result) =>
                  #      env.logger.debug JSON.stringify(result)
                  #    )
                  #  )
              )
        )

    connect: () =>
      @Connector = new InfluxConnection(@ip,@port)
      @Connector.on "ready", =>
        @ready = true
        @emit "ready"
      @Connector.on "notready", =>
        @ready = false

  class InfluxVariable extends env.devices.Device

    constructor: (@config, lastState, @framework, plugin) ->
      @id = @config.id
      @name = @config.name
      @attributes = {}
      @vars = {}
      @influx = plugin
      for variable in @config.variables
        do (variable) =>
          name = variable.name
          info = null

          if @attributes[name]?
            throw new Error(
              "Two variables with the same name in VariablesDevice config \"#{name}\""
            )

          @attributes[name] = {
            description: name
            label: (if variable.label? then variable.label else "$#{name}")
            type: "number"
          }

          if variable.unit? and variable.unit.length > 0
            @attributes[name].unit = variable.unit

          if variable.acronym?
            @attributes[name].acronym = variable.acronym

          @vars[name] = {
            value: 0
            query: variable.query
            database: variable.database
          }

          getValue = ( () =>
            return @vars[name].value
          )
          @_createGetter(name, getValue)

      @reconnect = setInterval =>
        if @influx.ready
          for name of @vars
            do (name) =>
              @influx.Connector.query(@vars[name].query, @vars[name].database).then( (result) =>
                env.logger.debug "Get value " + name + " - " + result[0].last
                @emit name, result[0].last
              ).catch( (err)=>
                env.logger.error err.message
              )
      ,@config.interval*1000

      super()

    destroy: ->
      clearTimeout(@reconnect) if @reconnect?
      super()

  class InfluxConfigExtension
    configSchema:
      influx:
        description: "Additional options for pimatic-influx"
        type: "object"
        required: false
        properties:
          active:
            description: "save all attributes with type <number> to influxdb"
            type: "boolean"
            default: false

    extendConfigShema: (schema) ->
      for name, def of @configSchema
        schema.properties[name] = _.cloneDeep(def)

    applicable: (schema) ->
      return yes

    apply: (config, device) -> # do nothing here


  myinfluxdbplugin = new Influxdbplugin()
  return myinfluxdbplugin
