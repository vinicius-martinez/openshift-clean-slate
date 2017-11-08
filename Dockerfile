FROM registry.access.redhat.com/rhel7-atomic
LABEL io.k8s.description="A container for cleaning the slate of target DeploymentConfigs on a given schedule" io.k8s.display-name="Openshift Clean Slate"

ADD scripts/clean-slate.sh /opt/app/scripts/

RUN microdnf --enablerepo=rhel-7-server-rpms --enablerepo=rhel-7-server-ose-3.6-rpms \
			install atomic-openshift-clients --nodocs ;\
			microdnf clean all
			
RUN	chgrp -R 0 /opt/app/scripts/ \
	chmod -R g+rw /opt/app/scripts/ \
	find /opt/app/scripts/ -type d -exec chmod g+x {} + \
	chmod +x /opt/app/scripts/*
			
CMD ["/opt/app/scripts/clean-slate.sh"]