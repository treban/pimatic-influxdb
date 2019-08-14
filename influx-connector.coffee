module.exports = (env) ->

  Influx = require 'influx'
  events = require 'events'
  Promise = env.require 'bluebird'

  class InfluxConnection extends events.EventEmitter

    constructor: (ip,port,database="pimatic") ->
      super()
      @ready=false
      @ip=ip
      @port=port
      @database=database
      @connect()
      reconnect = setInterval =>
        if not @ready
          @emit 'notready'
          @connect()
        else
          @ready=false
          @influxcon.ping(5000).then( (hosts) =>
            hosts.forEach( (host) =>
              if host.online
                env.logger.debug "influxdb keep alive check ok"
                @ready=true
              else
                env.logger.debug "keep alive not responding"
            )
          ).catch( (err) =>
            env.logger.error err.message
          )
      ,30000

    connect: () =>
      env.logger.debug "reconnecting to influxdb"
      @influxcon = new Influx.InfluxDB('http://'+@ip+":"+@port+'/'+@database)

      @influxcon.getDatabaseNames().then( (dbs) =>
        if (!dbs.includes(@database))
          env.logger.debug "pimatic database not found"
          env.logger.debug "creating new pimatic database"
          @influxcon.createDatabase(@database)
        @ready=true
        @emit 'ready'
        env.logger.debug "pimatic database ok"
      ).catch( (err) =>
        env.logger.error "could not connect to influxdb"
      )

    getDatabaseNames: () =>
      return @influxcon.getDatabaseNames()

    getMeasurements: (db) =>
      return @influxcon.getMeasurements(db)

    getSeries: (measure,db) =>
      return @influxcon.getSeries({measurement: measure, database: db})

    query: (query,db=pimatic) =>
      env.logger.debug query
      return @influxcon.query(query,{database: db})

    writeMeasurement: (tags,fields) =>
      return @influxcon.writeMeasurement('attribute', [
        {
          tags: tags,
          fields: fields
        }
      ])
