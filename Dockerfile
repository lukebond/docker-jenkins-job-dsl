FROM jenkins/jenkins:lts

# install Docker and kubectl
USER root
RUN \
  apt-get update && \
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    jq \
    software-properties-common && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable" && \
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  touch /etc/apt/sources.list.d/kubernetes.list && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
  apt-get update && \
  apt-get install -y docker-ce kubectl && \
  curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

COPY plugins.txt /var/jenkins_home/plugins.txt
RUN /usr/local/bin/plugins.sh /var/jenkins_home/plugins.txt

# Adding default Jenkins Jobs
COPY jobs/pipeline-job-1.xml /usr/share/jenkins/ref/jobs/pipeline-job-1/config.xml
COPY jobs/pipeline-job-1 /opt/repo/
USER root
RUN cd /opt/repo && \
  git init && \
  git config user.email "info@control-plane.io" && \
  git config user.name "cp-training" && \
  git add Jenkinsfile && \
  git commit -m "Initial commit" && \
  chown -R jenkins .

############################################
# Configure Jenkins
############################################
# Jenkins settings
COPY config/config.xml /usr/share/jenkins/ref/config.xml
