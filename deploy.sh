#! /bin/bash
################################################################################
# Sends archives of this repo to different machines to run the application in  #
# distributed systems.                                                         #
################################################################################

readonly PROGNAME="${0}"

source ./utils.sh

function print_usage {
	echo "Usage: ${PROGNAME} <proxy-ip> <coder-ip> <redis-ip> <client-ip> <env-file>"
	echo ""
	echo "Archives and sends the application to the designated IP addresses for execution"
	echo ""
	echo "Arguments:"
	echo -e "\tproxy-ip     IP address of the machine that will host the proxy instance"
	echo -e "\tcoder-ip     IP address of the machine that will host the encoder/decoder instance"
	echo -e "\tredis-ip     IP address of the machine that will host the redis instance"
	echo -e "\tclient-ip    IP address of the machine that will host the benchmarking client"
	echo -e "\tenv-file     A file containing configuration values that the application should be using"
	echo ""
}

if [[ "${#}" -ne 5 ]]; then
	print_usage
	exit 0
fi

readonly PROXY_HOST="${1}"
readonly CODER_HOST="${2}"
readonly REDIS_HOST="${3}"
readonly CLIENT_HOST="${4}"
readonly ENV_FILE="${5}"

readonly EXPORTS="\
export PROXY_PORT_3000_TCP_ADDR=${PROXY_HOST} \
export PROXY_PORT_3000_TCP_PORT=3000 \
export CODER_PORT_1234_TCP_ADDR=${CODER_HOST} \
export CODER_PORT_1234_TCP_PORT=1234 \
export REDIS_PORT_6379_TCP_ADDR=${REDIS_HOST} \
export REDIS_PORT_6379_TCP_PORT=7000"

echo -e "\
export PROXY_PORT_3000_TCP_ADDR=${PROXY_HOST}\n\
export PROXY_PORT_3000_TCP_PORT=3000\n\
export CODER_PORT_1234_TCP_ADDR=${CODER_HOST}\n\
export CODER_PORT_1234_TCP_PORT=1234\n\
export REDIS_PORT_6379_TCP_ADDR=${REDIS_HOST}\n\
export REDIS_PORT_6379_TCP_PORT=7000\n" > exports.source

echo -e "\
PROXY_PORT_3000_TCP_ADDR=${PROXY_HOST}\n\
PROXY_PORT_3000_TCP_PORT=3000\n\
CODER_PORT_1234_TCP_ADDR=${CODER_HOST}\n\
CODER_PORT_1234_TCP_PORT=1234\n\
REDIS_PORT_6379_TCP_ADDR=${REDIS_HOST}\n\
REDIS_PORT_6379_TCP_PORT=7000\n" > exports.env

archive="$(archive_repo)"

setup_proxy  "${PROXY_HOST}"  "${archive}" "${ENV_FILE}"
setup_coder  "${CODER_HOST}"  "${archive}" "${ENV_FILE}"
setup_redis  "${REDIS_HOST}"  "${archive}" "${ENV_FILE}"
setup_client "${CLIENT_HOST}" "${archive}" "${ENV_FILE}"
