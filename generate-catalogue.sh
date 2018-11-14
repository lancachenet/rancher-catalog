#!/bin/bash

set -e

function build_fullstack() {

	TEMPLATEDIR=${1-0}

	mkdir -p ${PWD}/templates/lancache-fullstack/${TEMPLATEDIR}


	DOCKERFILE=${PWD}/templates/lancache-fullstack/${TEMPLATEDIR}/docker-compose.yml
	RANCHERFILE=${PWD}/templates/lancache-fullstack/${TEMPLATEDIR}/rancher-compose.yml
	
	DOCKER_TEMPLATE=${PWD}/build/lancache-fullstack/docker-compose.yml
	RANCHER_TEMPLATE=${PWD}/build/lancache-fullstack/rancher-compose.yml
	SERVICES=${PWD}/build/services.yml

	echo Fullstack Dockerfile: ${DOCKERFILE}
	echo Fullstack Rancherfile: ${RANCHERFILE}

	cat ${DOCKER_TEMPLATE}.tmpl > ${DOCKERFILE}
	cat ${RANCHER_TEMPLATE}.tmpl | sed "s/version: 1.0./version: 1.0.${TEMPLATEDIR}/" > ${RANCHERFILE}
	
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
	        echo "    environment:" >> ${DOCKERFILE}
	        echo "      CACHE_DISK_SIZE: \${CACHE_DISK_SIZE}m" >> ${DOCKERFILE}
	        echo "      CACHE_MEM_SIZE: \${CACHE_MEM_SIZE}m" >> ${DOCKERFILE}
	        echo "      CACHE_MAX_AGE: \${CACHE_MAX_AGE}d" >> ${DOCKERFILE}
	
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
		
	rm ${SERVICES}

}

function build_dns() {

	TEMPLATEDIR=${1-0}
	
	mkdir -p ${PWD}/templates/lancache-dns/${TEMPLATEDIR}
	
	DOCKERFILE=${PWD}/templates/lancache-dns/${TEMPLATEDIR}/docker-compose.yml
	RANCHERFILE=${PWD}/templates/lancache-dns/${TEMPLATEDIR}/rancher-compose.yml
	
	DOCKER_TEMPLATE=${PWD}/build/lancache-dns/docker-compose.yml
	RANCHER_TEMPLATE=${PWD}/build/lancache-dns/rancher-compose.yml
	SERVICES=${PWD}/build/services.yml
	
	echo Dns Dockerfile: ${DOCKERFILE}
	echo Dns Rancherfile: ${RANCHERFILE}

	cat ${DOCKER_TEMPLATE}.tmpl > ${DOCKERFILE}
	cat ${RANCHER_TEMPLATE}.tmpl | sed "s/version: 1.0./version: 1.0.${TEMPLATEDIR}/" > ${RANCHERFILE}
	
	cat services.json | jq -r '.cache_domains[] | .name' | while read L; do
	## For each service, we want to add the service to the dockerfile. The default dockerfile should only have the loadbalancer, dns & sni-proxy defined
	    if ! echo ${L} | grep "\.txt" ; then
			SERVICE=${L}
	        echo "${SERVICE}"
		    
	        echo "      ${SERVICE^^}_IP: \${SERVICE_IP}" >> ${DOCKERFILE}
	        echo "      DISABLE_${SERVICE^^}: \${DISABLE_SERVICE}" >> ${DOCKERFILE}
	    
	        echo "    - variable: \"DISABLE_${SERVICE^^}\"" >> ${RANCHERFILE}
	        echo "      label: Disable ${SERVICE} DNS" >> ${RANCHERFILE}
			echo "      default: true" >> ${RANCHERFILE}
	        echo "      required: true" >> ${RANCHERFILE}
	        echo "      type: boolean" >> ${RANCHERFILE}
	        echo "    - variable: \"${SERVICE^^}_IP\"" >> ${RANCHERFILE}
	        echo "      label: ${SERVICE} Cache IP Address" >> ${RANCHERFILE}
			echo "      default: 10.0.0.1" >> ${RANCHERFILE}
	        echo "      required: false" >> ${RANCHERFILE}
	        echo "      type: string" >> ${RANCHERFILE}
		fi

	done

	cat ${RANCHER_TEMPLATE}.tmpl.tail | sed "s/version: 1.0./version: 1.0.${TEMPLATEDIR}/" >> ${RANCHERFILE}


}

function main() {


	curl -s -o services.json https://raw.githubusercontent.com/uklans/cache-domains/master/cache_domains.json

	if [[ "${1}" == "fullstack" ]]; then
		COMMAND=${2}
		build_fullstack $COMMAND;
	elif [[ "${1}" == "dns" ]]; then
		COMMAND=${2}
		build_dns $COMMAND;
	else
		COMMAND=$1
		build_fullstack $COMMAND;
		build_dns $COMMAND;
	fi

	rm services.json


}


main $@
