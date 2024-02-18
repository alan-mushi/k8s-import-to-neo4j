#!/bin/bash -x

podman run -d --rm --name=neo4j \
	-p 7474:7474 -p 7687:7687 \
	-e NEO4J_AUTH=none \
	-e NEO4J_apoc_export_file_enabled=true \
	-e NEO4J_apoc_import_file_enabled=true \
	-e NEO4J_apoc_import_file_use__neo4j__config=false \
	-e NEO4JLABS_PLUGINS=\[\"apoc\",\"apoc-extended\"\] \
	-v ./cluster_dump/:/mnt/:z \
	-v ./import_queries:/import_queries/:z \
	neo4j:latest
