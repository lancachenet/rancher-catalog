#!/bin/bash

set -e

TEMPLATEDIR=${1-0}

mkdir -p ${PWD}/templates/lancache-fullstack/${TEMPLATEDIR}

DOCKERFILE=${PWD}/templates/lancache-fullstack/${TEMPLATEDIR}/docker-compose.yml
RANCHERFILE=${PWD}/templates/lancache-fullstack/${TEMPLATEDIR}/rancher-compose.yml

DOCKER_TEMPLATE=${PWD}/build/docker-compose.yml
RANCHER_TEMPLATE=${PWD}/build/rancher-compose.yml
SERVICES=${PWD}/build/services.yml

curl -s -o services.json https://raw.githubusercontent.com/uklans/cache-domains/master/cache_domains.json

cat ${DOCKER_TEMPLATE}.tmp > ${DOCKERFILE}
cat ${RANCHER_TEMPLATE}.tmp | sed "s/version: 1.0./version: 1.0.${TEMPLATEDIR}/" > ${RANCHERFILE}

cat services.json | jq -r '.cache_domains[] | .name, .domain_files[]' | while read L; do
#cat services.json | jq -r .cache_domains[].name  | while read SERVICE ; do
## For each service, we want to add the service to the dockerfile. The default dockerfile should only have the loadbalancer, dns & sni-proxy defined
    if ! echo ${L} | grep "\.txt" ; then
	SERVICE=${L}
	if [ "${SERVICE}" = "steam" ]; then
		CONTAINER="\${STEAMCACHE_CONTAINER}"
	else
		CONTAINER="generic"
	fi
        echo "${SERVICE}"
    
        echo "  ${SERVICE}:" >> ${DOCKERFILE}
        echo "    image: steamcache/${CONTAINER}:latest" >> ${DOCKERFILE}
        echo "    volumes:" >> ${DOCKERFILE}
        echo "      - \${CACHE_ROOT}/${SERVICE}/cache:/data/cache" >> ${DOCKERFILE}
        echo "      - \${CACHE_ROOT}/${SERVICE}/logs:/data/logs" >> ${DOCKERFILE}

        echo "  ${SERVICE}:" >> ${SERVICES}
        echo "    scale: 1" >> ${SERVICES}
        echo "    start_on_create: true" >> ${SERVICES}
    else

	curl -s -o ${L} https://raw.githubusercontent.com/uklans/cache-domains/master/${L}
	## files don't have a newline at the end
	echo -e -n "\n" >> ${L}
	cat ${L} | grep -v "^#" | while read URL; do

	if [ "x${URL}" != "x" ] ; then
	echo " - ${URL}"
        if ! grep "${URL}" ${RANCHERFILE} >/dev/null 2>&1 ; then
            echo "      - hostname: '${URL}'" >> ${RANCHERFILE}
            echo "        path: ''" >> ${RANCHERFILE}
            echo "        access: public" >> ${RANCHERFILE}
            echo "        priority: 1" >> ${RANCHERFILE}
            echo "        protocol: http" >> ${RANCHERFILE}
            echo "        service: ${SERVICE}" >> ${RANCHERFILE}
            echo "        source_port: 80" >> ${RANCHERFILE}
            echo "        target_port: 80" >> ${RANCHERFILE}
        fi
	fi
	done
rm ${L}
    fi

done

cat ${SERVICES} >> ${RANCHERFILE}

rm services.json
rm ${SERVICES}

