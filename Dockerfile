FROM registry.access.redhat.com/rhel7-atomic
LABEL io.k8s.description="A container for scaling DeploymentConfigs on a given schedule" io.k8s.display-name="Openshift Shcheduled Scaling"

ADD scripts/scale.sh /opt/app/scripts/

RUN microdnf --enablerepo=rhel-7-server-rpms \
			install tar gzip --nodocs ;\
			microdnf clean all ;\
			curl --retry 5 -Lso /tmp/client-tools.tar.gz https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-client-tools-v3.9.0-191fece-linux-64bit.tar.gz ;\
			tar zxf /tmp/client-tools.tar.gz --strip-components=1 -C /usr/local/bin
			
RUN	chgrp -R 0 /opt/app/scripts/ ;\
	chmod -R g+rw /opt/app/scripts/ ;\
	find /opt/app/scripts/ -type d -exec chmod g+x {} + ;\
	chmod +x /opt/app/scripts/*
			
CMD ["/opt/app/scripts/scale.sh"]
