module.exports = {
  title: "Influxdb plugin config options"
  type: "object"
  required: []
  properties:
    debug:
      description: "Enabled debug messages"
      type: "boolean"
      default: false
    ip:
      description: "IP address from the influxdb rest api"
      type: "string"
      required: true
    port:
      description: "port from the influxdb rest api"
      type: "string"
      default: 8086
    interval:
      description: "interval to send values to influx periodically, 0 = turn OFF "
      type:"number"
      default: 0
}
