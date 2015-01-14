FROM centos:centos6
MAINTAINER Kohei Kinoshita <aozora0000@gmail.com>

# EPEL/REMIインストール
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN yum -y update && \
    yum -y install ansible && \
    yum -y update gmp

# ansible provisioning
ADD ./playbook.yml /tmp/ansible/
WORKDIR /tmp/ansible
RUN ansible-playbook playbook.yml

# pyenvインストール
USER worker
WORKDIR /home/worker/
RUN git clone git://github.com/yyuu/pyenv.git /home/worker/.pyenv && \
    echo "export PATH=/home/worker/.pyenv/bin:$PATH" >> /home/worker/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> /home/worker/.bashrc

ENV PYTHON_VERSION 3.3.6

RUN source /home/worker/.bashrc && \
    pyenv install "$PYTHON_VERSION" && \
    pyenv rehash && \
    pyenv global "$PYTHON_VERSION" && \
    python --version && pip --version

#################################
# default behavior is to login by worker user
#################################
CMD ["su", "-", "worker"]
