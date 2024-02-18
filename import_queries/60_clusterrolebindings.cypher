// start 60_clusterrolebindings.cypher

CALL apoc.load.json('/mnt/clusterrolebindings.rbac.authorization.k8s.io.json')
YIELD value
UNWIND value.items as crbJson
MERGE (crb:ClusterRoleBinding {name: crbJson.metadata.name})
ON CREATE SET crb.json = apoc.convert.toJson(crbJson)

// Deals with roleRef
FOREACH (_ IN CASE WHEN crbJson.roleRef.kind = 'ClusterRole' THEN [1] ELSE [] END |
    MERGE (cr:ClusterRole {name: crbJson.roleRef.name})
    MERGE (crb)-[:ROLE]->(cr)
)

// Deals with subjects
FOREACH (subjectJson IN crbJson.subjects |
    FOREACH (_ IN CASE WHEN subjectJson.kind = 'Group' THEN [1] ELSE [] END |
        MERGE (group:Group {name: subjectJson.name})
        MERGE (crb)-[:ROLE_SUBJECT]->(group)
    )
    FOREACH (_ IN CASE WHEN subjectJson.kind = 'User' THEN [1] ELSE [] END |
        MERGE (user:User {name: subjectJson.name})
        MERGE (crb)-[:ROLE_SUBECT]->(user)
    )
    FOREACH (_ IN CASE WHEN subjectJson.kind = 'ServiceAccount' THEN [1] ELSE [] END |
        MERGE (sa:ServiceAccount {
            name: subjectJson.name, 
            namespace: subjectJson.namespace,
            qualifiedName: 'system:serviceaccount:' + subjectJson.namespace + ':' + subjectJson.name
        })
        MERGE (crb)-[:ROLE_SUBECT]->(sa)
    )
)
;
// end 60_clusterrolebindings.cypher
