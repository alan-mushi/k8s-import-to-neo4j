CALL apoc.load.json('/mnt/' + $namespace + '/serviceaccounts.json')
YIELD value
UNWIND value.items as saJson
MERGE (sa:ServiceAccount {
    name: saJson.metadata.name,
    namespace: saJson.metadata.namespace,
    qualifiedName: 'system:serviceaccount:' + saJson.metadata.namespace + ':' + saJson.metadata.name,
    json: apoc.convert.toJson(saJson)
})

FOREACH (secretJson IN saJson.secrets |
    MERGE (sec:Secret {name: secretJson.name, namespace: saJson.metadata.namespace})
    MERGE (sa)-[:REF_SECRET]->(sec)
)

FOREACH (imagePullSecretJson IN saJson.imagePullSecrets |
    MERGE (sec:Secret {name: imagePullSecretJson.name, namespace: saJson.metadata.namespace})
    MERGE (sa)-[:REF_SECRET]->(sec)
)
