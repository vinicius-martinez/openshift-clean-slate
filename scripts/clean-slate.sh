#!/bin/bash

if [ -f /run/secrets/kubernetes.io/serviceaccount/token ]; then
	TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`
	CA=/run/secrets/kubernetes.io/serviceaccount/ca.crt
else
	echo "No token found. Are you running on OpenShift?"
fi

# Make sure we're logged in
if [ -n "$TOKEN" ]; then
	echo "Authenticating with token"
	oc login $KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT --token=$TOKEN --certificate-authority=$CA
fi

# Iterate through DCs, and execute a rollout on them
if [ -n "$DEPLOYMENT_CONFIGS" ]; then
	for dc in $(echo $DEPLOYMENT_CONFIGS | sed "s/,/ /g")
	do
		echo "--"
		echo "Cleaning the slate of $dc"
		oc rollout latest dc/$dc
		echo "Done"
	done
else
	echo "No DeploymentConfigs specified. Skipping execution."
fi