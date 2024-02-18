// start 10_namespaces.cypher

CALL apoc.load.json('/mnt/namespaces.json')
YIELD value
UNWIND value.items AS namespaceJson
CALL apoc.cypher.runFiles([
    "/import_queries/namespaced/20_secrets.cypher",
    "/import_queries/namespaced/25_roles.cypher",
    "/import_queries/namespaced/25_serviceaccounts.cypher",
    "/import_queries/namespaced/30_rolebindings.cypher",
    "/import_queries/namespaced/40_pods.cypher"
    // "/import_queries/namespaced/40_endpointslices.cypher",
    // "/import_queries/namespaced/41_routes.cypher",
], {parameters: {namespace: namespaceJson.metadata.name}})
YIELD row, result
RETURN result
;
// end 10_namespaces.cypher
