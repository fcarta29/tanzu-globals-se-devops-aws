FROM ubuntu:18.04
LABEL maintainer="Frank Carta <fcarta@vmware.com>"

ENV KUBECTL_VERSION=v1.19.6
ENV ARGOCD_CLI_VERSION=v1.7.7
ENV ARGOCD_VERSION=v2.0.1
ENV KPACK_VERSION=0.3.1
ENV ISTIO_VERSION=1.7.4
ENV TKN_VERSION=0.17.2
ENV KPDEMO_VERSION=v0.3.0
ENV TANZU_CLI_VERSION=v1.3.1
ENV KUBESEAL_VERSION=v0.15.0
ENV KREW_VERSION=v0.4.1

# Install System libraries
RUN echo "Installing System Libraries" \
  && apt-get update \
  && apt-get install -y build-essential python3.6 python3-pip python3-dev groff bash-completion git curl unzip wget findutils jq vim tree docker.io moreutils

# Install AWS CLI
RUN echo "Installing AWS CLI" \
  && pip3 install --upgrade awscli

# Install TMC CLI
COPY bin/tmc .
RUN echo "Installing TMC CLI" \
  && chmod +x tmc \
  && mv tmc /usr/local/bin/tmc \
  && which tmc \
  && tmc version

# Install Tanzu CLI
COPY bin/tanzu-cli-bundle-${TANZU_CLI_VERSION}-linux-amd64.tar .
RUN echo "Installing Tanzu CLI" \
  && mkdir -p tanzu \
  && tar xvf tanzu-cli-bundle-${TANZU_CLI_VERSION}-linux-amd64.tar -C tanzu \
  && cd tanzu/cli \
  && install core/${TANZU_CLI_VERSION}/tanzu-core-linux_amd64 /usr/local/bin/tanzu \
  && tanzu version 

# Install Tanzu CLI Plugins
RUN echo "Installing Tanzu CLI Plugins" \
  && cd tanzu \
  && tanzu plugin install --local cli all \
  && tanzu plugin list

# Install Tanzu Extensions
COPY bin/tkg-extensions-manifests-${TANZU_CLI_VERSION}-vmware.1.tar.gz .
RUN echo "Installing Tanzu Extensions" \
  && tar -xzf tkg-extensions-manifests-v1.3.1-vmware.1.tar.gz -C tanzu

# Install Kubectl
RUN echo "Installing Kubectl" \
  && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && which kubectl \
  && mkdir -p /etc/bash_completion.d \
  && kubectl completion bash > /etc/bash_completion.d/kubectl \
  && kubectl version --short --client

# Install Kubectl vSphere Plugin
COPY bin/kubectl-vsphere .
RUN echo "Installing Kubectl vSphere Plugin" \
  && mv kubectl-vsphere  /usr/local/bin/kubectl-vsphere  \
  && chmod +x /usr/local/bin/kubectl-vsphere

# Install Kustomize
RUN echo "Installing Kustomize" \
  && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash \
  && mv kustomize /usr/local/bin/kustomize \
  && kustomize version

# Install Helm3
RUN echo "Installing Helm3" \
  && curl https://get.helm.sh/helm-v3.3.0-rc.2-linux-amd64.tar.gz --output helm.tar.gz \
  && tar -zxvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm \
  && helm version

# Install KPACK CLI
COPY bin/kp-linux-${KPACK_VERSION} .
RUN echo "Installing kpack CLI" \
  && chmod +x kp-linux-${KPACK_VERSION} \
  && mv kp-linux-${KPACK_VERSION} /usr/local/bin/kp \
  && which kp \
  && kp version

# Get kpack install yaml install and log utility
RUN echo "Installing kpack log utility" \
  && mkdir /opt/kpack \
  && curl -sSL -o /opt/kpack/logs-v${KPACK_VERSION}-linux.tgz https://github.com/pivotal/kpack/releases/download/v${KPACK_VERSION}/logs-v${KPACK_VERSION}-linux.tgz \
  && tar -zxvf /opt/kpack/logs-v${KPACK_VERSION}-linux.tgz \
  && mv logs /usr/local/bin/logs \
  && chmod +x /usr/local/bin/logs

# Install Carvel tools
RUN echo "Installing K14s Carvel tools" \
  && wget -O- https://carvel.dev/install.sh | bash

# Install Istioctl
RUN echo "Installing Istioctl" \
  && curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh - \
  && cd istio-${ISTIO_VERSION} \
  && cp $PWD/bin/istioctl /usr/local/bin/istioctl \
  && istioctl version

# Install ArgoCD
RUN echo "Installing ArgoCD" \
  && curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64 \
  && chmod +x /usr/local/bin/argocd 
  #&& argocd version

# Install Bitnami Sealed Secrets
RUN echo "Installing Bitnami Sealed Secrets" \
  && wget https://github.com/bitnami-labs/sealed-secrets/releases/download/$KUBESEAL_VERSION/kubeseal-linux-amd64 -O kubeseal \
  && install -m 755 kubeseal /usr/local/bin/kubeseal

# Install Tekton CLI
RUN echo "Installing Tekton CLI" \
  && curl -LO https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz --output tkn_${TKN_VERSION}_Linux_x86_64.tar.gz \
  && tar xvzf tkn_${TKN_VERSION}_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn \
  && chmod +x /usr/local/bin/tkn \
  && tkn version

# Install Krew - needed for kubectx and kubens
RUN echo "Installing Krew" \
  && (set -x; cd "$(mktemp -d)" \
  && OS="$(uname | tr '[:upper:]' '[:lower:]')" \
  && ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" \
  && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/$KREW_VERSION/krew.tar.gz" \
  && tar zxvf krew.tar.gz \
  && KREW=./krew-"${OS}_${ARCH}" \
  && "$KREW" install krew) \
  && echo "export PATH=${KREW_ROOT:-$HOME/.krew}/bin:$PATH" >> /root/.bashrc

# Install Kubectx - need the PATH here because export above doesnt seem to take in effect yet here?
RUN echo "Installing kubectx" \
  && PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" \
  && kubectl krew install ctx

# Install Kubens - need the PATH here because export above doesnt seem to take in effect yet here?
RUN echo "Installing kubens" \
  && PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" \
  kubectl krew install ns

# Create Aliases
RUN echo "alias k=kubectl" >> /root/.profile \
  && echo "alias kubectx='kubectl ctx'" >> /root/.profile \
  && echo "alias kubens='kubectl ns'" >> /root/.profile

# Install bat
RUN echo "Installing bat" \  
  && curl -L https://github.com/sharkdp/bat/releases/download/v0.18.1/bat-v0.18.1-x86_64-unknown-linux-gnu.tar.gz --output bat-v0.18.1-x86_64-unknown-linux-gnu.tar.gz \
  && tar -zxvf bat-v0.18.1-x86_64-unknown-linux-gnu.tar.gz \
  && mv bat-v0.18.1-x86_64-unknown-linux-gnu /usr/local/bin/. \
  && ln -s /usr/local/bin/bat-v0.18.1-x86_64-unknown-linux-gnu/bat /usr/local/bin/bat

# Leave Container Running for SSH Access - SHOULD REMOVE
ENTRYPOINT ["tail", "-f", "/dev/null"]

