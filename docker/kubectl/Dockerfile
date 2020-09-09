FROM ubuntu
RUN apt-get update && apt-get install -y curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN mv kubectl /usr/bin/kubectl && chmod a+x /usr/bin/kubectl
COPY kube-config /root/.kube/config
RUN chmod 700 /root/.kube -R
