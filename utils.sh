#!/bin/bash
################################################################################
# Utility bash function for the playcloud project                              #
################################################################################

################################################################################
# archive_repo
#
# Creates an archive from the local repository based on the last commit of the
# current branch.
#
# Return values:
# - path to the newly created archive
################################################################################
function archive_repo {
	local branch="$(git rev-parse --abbrev-ref HEAD)"
  local directory="$(basename "${PWD}")"
	local archive_path="/tmp/${directory}.tar.gz"
	git archive -o "${archive_path}" "${branch}"
	echo "${archive_path}"
}

################################################################################
# setup_proxy
#
# A function that sends all the files required to operate a playcloud proxy to a
# machine using scp and (re-)starts the proxy.
#
# Parameters:
# 1: host           The machine files should be sent to
# 2: archive        The archive of the repo that should be used to run the proxy
# 3: env_file       The environment files with the values that should be used by
#                   the application
################################################################################
function setup_proxy {
  local host="${1}"
  local archive="${2}"
  local directory="$(basename "${PWD}")"
  local env_file="${3}"
	scp -o "StrictHostKeyChecking no" "${archive}" exports.source exports.env "${env_file}" "${host}:"
	ssh "${host}" "mkdir -p app/ && tar xf ${directory}.tar.gz --directory app/ && \
	source exports.source && cd app/  && cp ${env_file} erasure.env && sed --in-place 's/^export //' erasure.env && \
	docker-compose -f compose-proxy.yml ps -q | xargs docker rm -f -v ; docker-compose -f compose-proxy.yml up -d"
}


################################################################################
# setup_coder
#
# A function that sends all the files required to operate a playcloud encoder/decoder to a
# machine using scp and (re-)starts the encode/decoder.
#
# Parameters:
# 1: host           The machine files should be sent to
# 2: archive        The archive of the repo that should be used to run the encoder/decoder
# 3: env_file       The environment files with the values that should be used by
#                   the application
################################################################################
function setup_coder {
  local host="${1}"
  local archive="${2}"
  local directory="$(basename "${PWD}")"
  local env_file="${3}"
	scp -o "StrictHostKeyChecking no" "${archive}" exports.source exports.env "${env_file}" "${host}:"
	ssh "${host}" "mkdir -p app/ && tar xf ${directory}.tar.gz --directory app/ && \
	source exports.source && cd app/  && cp ${env_file} erasure.env && sed --in-place 's/^export //' erasure.env && \
	docker-compose -f compose-coder.yml ps -q | xargs docker rm -f -v ;  docker-compose -f compose-coder.yml up -d"
}


################################################################################
# setup_redis
#
# A function that sends all the files required to operate a redis instance to a
# machine using scp  and (re-)starts redis
#
# Parameters:
# 1: host           The machine files should be sent to
# 2: archive        The archive of the repo that should be used to run redis
# 3: env_file       The environment files with the values that should be used by
#                   the application
################################################################################
function setup_redis {
  local host="${1}"
  local archive="${2}"
  local directory="$(basename "${PWD}")"
  local env_file="${3}"
  scp -o "StrictHostKeyChecking no" "${archive}" exports.source exports.env "${env_file}" "${host}:"
  ssh "${host}" "mkdir -p app/ && tar xf ${directory}.tar.gz --directory app/ && \
  source exports.source && cd app/  && cp ${env_file} erasure.env && sed --in-place 's/^export //' erasure.env && \
  docker-compose -f compose-redis.yml ps -q | xargs docker rm -f -v ; docker-compose -f compose-redis.yml up -d"
}

################################################################################
# setup_client
#
# A function that sends all the files required to operate a benchmarking client
# to a machine using scp.
#
# Parameters:
# 1: host           The machine files should be sent to
# 2: archive        The archive of the repo that should be used to run the
#                   benchmarking client
# 3: env_file       The environment files with the values that should be used by
#                   the application
################################################################################
function setup_client {
  local host="${1}"
  local archive="${2}"
  local directory="$(basename "${PWD}")"
  local env_file="${3}"
  shift 3
  scp -o "StrictHostKeyChecking no" "${archive}" exports.source exports.env "${env_file}" "${host}:"
  ssh "${host}" "mkdir -p playcloud/ && tar xf ${directory}.tar.gz --directory playcloud/ && \
  cp ${directory}.tar.gz /tmp/ && cp exports.source playcloud/exports.source &&  cp exports.env playcloud/exports.env && \
  echo -e '\n$(cat exports.source)' >> /home/ubuntu/.bashrc && echo -e '\n$(cat exports.source)' >> /home/ubuntu/.profile && \
  source exports.source && cd playcloud/ && cp ${env_file} erasure.env && sed --in-place 's/^export //' erasure.env && \
	sudo apt-get install --quiet --assume-yes redis-tools"
}

################################################################################
# fetch_microbench_experimental_data
#
# A function that recovers microbench data from a list of servers from the
# cluster.
#
# Parameters:
# n: ips           IP addesses of the server on which microbench experiments
#                  werer run
################################################################################
function fetch_microbench_experimental_data {
  local ips=("${@}")
  for ip in "${ips[@]}"; do
    rsync --recursive --update --partial --compress --quiet -e \
          ssh "${ip}":app/xpdata/pyeclib/ data/pyeclib/
  done
}

################################################################################
# gen_random_data
#
# Generates a file of random data of size n MB where n is given as a parameter.
#
# Parameters:
# 1: size          Size in MB of the file to generate
# Return values:
# - path to the newly created file
################################################################################
function gen_random_data {
	if [[ "${#}" == 0 ]]; then
		echo "How to use:"
		echo "$0 size_of_random_data [MB]"
		return 1
	fi
	local size="${1}"
	local file="/tmp/random${size}.dat"
	if [[ -e "${file}" ]]; then
		echo "${file}"
		return 0
	fi
	dd if=/dev/urandom of="${file}" bs=1048576 count="${size}" > /dev/null 2>&1
	echo "${file}"
	return 0
}
