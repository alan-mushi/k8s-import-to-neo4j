// start 11_groups.cypher

CALL apoc.load.json('/mnt/groups.user.openshift.io.json')
YIELD value
UNWIND value.items as groupJson
MERGE (g:Group {name: groupJson.metadata.name, json: apoc.convert.toJson(groupJson)})

FOREACH (username IN groupJson.users |
    MERGE (u:User {name: username})
    MERGE (g)-[:REF_USER]->(u)
)
;
// end 11_groups.cypher