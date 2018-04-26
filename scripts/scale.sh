#!/bin/bash

if [ -f /run/secrets/kubernetes.io/serviceaccount/token ]; then
	TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`
	PROJECT=`cat /run/secrets/kubernetes.io/serviceaccount/namespace`
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
if [ -n "$DEPLOYMENT_CONFIGS" -a  -n "$REPLICA_COUNT" ]; then
	echo "--"
	echo "Scaling Deployment Config $DEPLOYMENT_CONFIGS with the following replica: $REPLICA_COUNT"
	oc scale --replicas=$REPLICA_COUNT dc $DEPLOYMENT_CONFIGS -n $PROJECT
	echo "Done"	
else
	echo "No DeploymentConfigs specified. Skipping execution."
fi
