Poor Man's OpenShift/Kubernetes API to Neo4J
============================================

0. [Dump](https://github.com/rh-tguittet/KubeHound/blob/collector-script-namespaced-resources/scripts/collectors/collect.sh)
   the resources you care about or configure the URL+Auth in the queries
1. Start the neo4j server: `./start_neo4j.sh`
2. Combine the import queries and paste that big blob into [neo4j's web
   interface](http://127.0.0.1:7474/): `cat import_queries/*.cypher`
3. Browse the results in the UI
