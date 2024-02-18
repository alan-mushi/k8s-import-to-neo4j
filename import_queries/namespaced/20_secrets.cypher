CALL apoc.load.json('/mnt/' + $namespace + '/secrets.json')
YIELD value
UNWIND value.items as secretJson
MERGE (s:Secret {
    name: secretJson.metadata.name,
    namespace: secretJson.metadata.namespace,
    json: apoc.convert.toJson(secretJson)
})

// TODO[Maybe]: deal with the data?