// start 10_users.cypher

CALL apoc.load.json('/mnt/users.user.openshift.io.json')
YIELD value
UNWIND value.items as userJson
MERGE (u:User {name: userJson.metadata.name, json: apoc.convert.toJson(userJson)})
;
// end 10_users.cypher
