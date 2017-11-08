#!/bin/bash

if [ -f /run/secrets/kubernetes.io/serviceaccount/token ]; then
	TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`
else
	echo "No token found. Are you running on OpenShift?"
fi

# Make sure we're logged in
if [ -n "$TOKEN" g]; then
	echo "Authenticating with token"
	oc login $KUBERNETES_SERVICE_HOST --token=$TOKEN --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt
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