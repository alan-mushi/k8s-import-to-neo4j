CALL apoc.load.json('/mnt/' + $namespace + '/pods.json')
YIELD value
UNWIND value.items as podJson
MERGE (p:Pod {
    name: podJson.metadata.name,
    namespace: podJson.metadata.namespace,
    json: apoc.convert.toJson(podJson)
})

// ServiceAccount
MERGE (s:ServiceAccount {
    name: podJson.spec.serviceAccountName,
    namespace: podJson.metadata.namespace,
    qualifiedName: 'system:serviceaccount:' + podJson.metadata.namespace + ':' + podJson.spec.serviceAccountName
})
MERGE (p)-[:POD_SERVICE_ACCOUNT_NAME]->(s)

// imagePullSecret
FOREACH ( imagePullSecretJson IN podJson.spec.imagePullSecrets |
    MERGE (imagePullSecret:Secret {name: imagePullSecretJson.name, namespace: podJson.metadata.namespace})
    MERGE (p)-[:REF_SECRET]->(imagePullSecret)
)

// Secrets in volumes
FOREACH ( volumesJson IN apoc.map.get(podJson.spec, "volumes", []) |
    // .spec.volumes[].secret.secretName
    FOREACH ( secretVolumeSourceJson IN apoc.map.get(volumesJson, "secret", []) | 
        MERGE (secretVolumeSource:Secret {name: secretVolumeSourceJson.secretName, namespace: podJson.metadata.namespace})
        MERGE (p)-[:REF_SECRET]->(secretVolumeSource)
    )

    FOREACH ( _ IN CASE WHEN "projected" in keys(volumesJson) THEN [1] ELSE [] END | 
        FOREACH ( projectedVolumeSourceJson IN volumesJson.projected.sources |
            // .spec.volumes[].projected.sources[].secret.name
            FOREACH ( _ IN CASE WHEN "secret" in keys(projectedVolumeSourceJson) THEN [1] ELSE [] END |
                MERGE (secretProjection:Secret {name: projectedVolumeSourceJson.secret.name, namespace: podJson.metadata.namespace})
                MERGE (p)-[:REF_SECRET]->(secretProjection)
            )
            // TODO[Maybe]: support downwardAPI
        )
    )
)

FOREACH ( containersJson IN podJson.spec.containers | 
    // Secrets in env
    FOREACH ( envVarJson IN apoc.map.get(containersJson, "env", []) |
        FOREACH ( _ IN CASE WHEN "valueFrom" in keys(envVarJson) THEN [1] ELSE [] END |
            // .spec.containers[].env[].valueFrom.secretKeyRef.name
            FOREACH ( _ IN CASE WHEN "secretKeyRef" in keys(envVarJson.valueFrom) THEN [1] ELSE [] END |
                MERGE (envSecret:Secret {name: envVarJson.valueFrom.secretKeyRef.name, namespace: podJson.metadata.namespace})
                MERGE (p)-[:REF_SECRET]->(envSecret)
            )
        )
    )

    // Secrets in envFrom
    FOREACH ( envFromSourceJson IN apoc.map.get(containersJson, "envFrom", []) |
        // .spec.containers[].envFrom[].secretRef.name
        FOREACH ( _ IN CASE WHEN "secretRef" in keys(envFromSourceJson) THEN [1] ELSE [] END |
            MERGE (envFromSecret:Secret {name: envFromSourceJson.secretRef.name, namespace: podJson.metadata.namespace})
            MERGE (p)-[:REF_SECRET]->(envFromSecret)
        )
    )
)

// TODO[Maybe]: create a container node?
// TODO[Maybe]: support downwardAPI