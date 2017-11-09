# OpenShift Clean Slate

### What Is It?

A templated Job in OpenShift which redeploys Pods based on a specific Cron Schedule. This 'cleaning of the slate' resets the Pod state to is initial state and serves to highlight several things:

- Whether containers in a Pod is following an anti-pattern by storing critical process state in ephemeral storage (Image Immutability Principle)
- Whether a container in a Pod is able to gracefully handle enforced shutdown / restart (Lifecycle Conformance Principle)
- Whether a Pod is a *snowflake* or not. (Process Disposability Principle)
- Whether Services that rely on this Pod are able to handle its absence gracefully (Self Containment Principle)
- Whether or not enough replicas of this Pod are maintained to allow service continuity during the redeployment.


### What It Is Not

Chaos Monkey. This is predictable and deliberate. Chaos Monkey is neither of those things. It might inadvertently test some of the same things, but it is not a replacement and should not be treated as such.

### Useage

**NOTE - This version can only be used with OpenShift 3.6 or later. Earlier versions do not correctly support referencing ImageStreams from a CronJob. The Fully Qualified Name of the Image must be used instead**

Give the executing OpenShift Service Account edit rights on the project:

`oc policy add-role-to-user edit system:serviceaccount:$(oc project -q):default -n $(oc project -q)`

Import the Template:

`oc create -f https://raw.githubusercontent.com/benemon/openshift-clean-slate/master/openshift/openshift-clean-slate.yaml`

A Dockerfile build should be started within your environment. When completed, instantiate the template from CLI, or via the web console providing the following parameters:

* `JOB_NAME` - A unique identifer for this CronJob
* `DEPLOYMENT_CONFIGS` - The DeploymentConfigs to target as part of the Clean Slate exercise
* `CRON_SCHEDULE` - The standard Cron schedule to follow

`oc process openshift-clean-slate JOB_NAME=kitchensink-refresh DEPLOYMENT_CONFIGS=kitchensink CRON_SCHEDULE="*/5 * * * *" | oc create -f -`

### What Gets Created?

* A BuildConfig for the openshift-clean-slate container
* A CronJob
* An ImageStream for the builder image (RHEL Atomic)
* An ImageStream for the openshift-clean-slate container. This must have its lookupPolicy set to 'true' otherwise the job will fail for the reasons mentioned above.
* A ConfigMap containing the targetted DeploymentConfigs, so it can be altered independently between job executions. ConfigMap integration with the Schedule doesn't work at present.
