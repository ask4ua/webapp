FROM ubuntu
RUN apt-get update && apt-get install -y curl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN mv kubectl /usr/bin/kubectl && chmod a+x /usr/bin/kubectl
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh &&./get_helm.sh
