CALL apoc.load.json('/mnt/' + $namespace + '/roles.rbac.authorization.k8s.io.json')
YIELD value
UNWIND value.items as roleJson
MERGE (r:Role {
    name: roleJson.metadata.name,
    namespace: roleJson.metadata.namespace,
    json: apoc.convert.toJson(roleJson)
})

// TODO[Maybe]: do something to model the resources pointed by the roles?