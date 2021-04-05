ARG JAVA_VERSION=8
ARG JBOSS_VERSION=10.1.0.Final

FROM openjdk:${JAVA_VERSION} AS builder

ARG ANT_VERSION=1.10.3
ARG ANT_HOME=/opt/apache-ant-${ANT_VERSION}

RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz

WORKDIR /app

COPY ./ ./

RUN cd ./edu.harvard.i2b2.server-common && \
    ${ANT_HOME}/bin/ant clean dist war

FROM jboss/wildfly:${JBOSS_VERSION}

COPY  --from=builder --chown=jboss:jboss /app/edu.harvard.i2b2.server-common/dist/i2b2.war ./wildfly/standalone/deployments
COPY --chown=jboss:jboss ./edu.harvard.i2b2.server-common/lib/jdbc/* ./wildfly/standalone/deployments/

# remove these in favor of using jboss CLI
COPY --chown=jboss:jboss ./edu.harvard.i2b2.crc/etc/jboss/crc-ds.xml ./wildfly/standalone/deployments
COPY --chown=jboss:jboss ./edu.harvard.i2b2.im/etc/jboss/im-ds.xml ./wildfly/standalone/deployments
COPY --chown=jboss:jboss ./edu.harvard.i2b2.ontology/etc/jboss/ont-ds.xml ./wildfly/standalone/deployments
COPY --chown=jboss:jboss ./edu.harvard.i2b2.pm/etc/jboss/pm-ds.xml ./wildfly/standalone/deployments
COPY --chown=jboss:jboss ./edu.harvard.i2b2.workplace/etc/jboss/work-ds.xml ./wildfly/standalone/deployments

