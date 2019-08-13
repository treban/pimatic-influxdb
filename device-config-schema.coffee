module.exports = {
  title: "influxdb"
  InfluxVariable: {
    title: "InfluxVariable config"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      interval:
        description: "interval to get values"
        type:"number"
        default: 10
      variables:
        description: "Variables to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          required: ["name", "query", "database"]
          properties:
            name:
              description: "Name for the corresponding attribute."
              type: "string"
            query:
              description: "The query to use to get the value."
              type: "string"
            database:
              description: "The database to use to get the value."
              type: "string"
            unit:
              description: "The unit of the variable"
              type: "string"
              required: false
            label:
              description: "A custom label to use in the frontend."
              type: "string"
              required: false
            acronym:
              description: "Acronym to show as value label in the frontend"
              type: "string"
              required: false
  }
}
