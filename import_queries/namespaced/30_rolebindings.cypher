CALL apoc.load.json('/mnt/' + $namespace + '/rolebindings.rbac.authorization.k8s.io.json')
YIELD value
UNWIND value.items as rbJson
MERGE (rb:RoleBinding {
    name: rbJson.metadata.name,
    namespace: rbJson.metadata.namespace,
    json: apoc.convert.toJson(rbJson)
})

// Deals with roleRef
FOREACH (_ IN CASE WHEN rbJson.roleRef.kind = 'Role' THEN [1] ELSE [] END |
    MERGE (r:Role {name: rbJson.roleRef.name, namespace: rbJson.metadata.name})
    MERGE (rb)-[:ROLE]->(r)
)

FOREACH (_ IN CASE WHEN rbJson.roleRef.kind = 'ClusterRole' THEN [1] ELSE [] END |
    MERGE (cr:ClusterRole {name: rbJson.roleRef.name})
    MERGE (rb)-[:ROLE]->(cr)
)

// Deals with subjects
FOREACH (subjectJson IN rbJson.subjects |
    FOREACH (_ IN CASE WHEN subjectJson.kind = 'Group' THEN [1] ELSE [] END |
        MERGE (group:Group {name: subjectJson.name})
        MERGE (rb)-[:ROLE_SUBJECT]->(group)
    )
    FOREACH (_ IN CASE WHEN subjectJson.kind = 'User' THEN [1] ELSE [] END |
        MERGE (user:User {name: subjectJson.name})
        MERGE (rb)-[:ROLE_SUBECT]->(user)
    )
    FOREACH (_ IN CASE WHEN subjectJson.kind = 'ServiceAccount' THEN [1] ELSE [] END |
        MERGE (sa:ServiceAccount {
            name: subjectJson.name,
            namespace: rbJson.metadata.namespace,
            qualifiedName: 'system:serviceaccount:' + rbJson.metadata.namespace + ':' + subjectJson.name
        })
        MERGE (rb)-[:ROLE_SUBECT]->(sa)
    )
)
