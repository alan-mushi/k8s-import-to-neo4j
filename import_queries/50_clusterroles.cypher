// start 50_clusterroles.cypher

CALL apoc.load.json('/mnt/clusterroles.rbac.authorization.k8s.io.json')
YIELD value
UNWIND value.items as crJson
MERGE (:ClusterRole {name: crJson.metadata.name, json: apoc.convert.toJson(crJson)})
;
// end 50_clusterroles.cypher
