ARG KSOPS_VERSION="v4.4.0"
ARG ARGOCD_VERSION="v3.2.3"
# Build revision for custom builds (empty by default, can be 0, 1, 2, -rc1, -beta1, etc.)
ARG BUILD_REVISION=""

# Get ksops binary from official ksops image since its distroless
# Cannot use InitContainer because of this issue: https://github.com/viaduct-ai/kustomize-sops/issues/300
# One of my reason I build this combined image is to avoid using InitContainer
FROM quay.io/viaductoss/ksops:$KSOPS_VERSION AS ksops

FROM quay.io/argoproj/argocd:$ARGOCD_VERSION
ARG SOPS_VERSION=3.11.0
ARG KUBECTL_VERSION=1.35.0
ARG VALS_VERSION=0.42.6
ARG AGE_VERSION=1.3.1
ARG HELM_SECRETS_VERSION=4.7.4
ARG STATIC_CURL_VERSION=8.17.0

ENV HELM_SECRETS_BACKEND="sops" \
  HELM_SECRETS_HELM_PATH="/usr/local/bin/helm" \
  # https://github.com/jkroepke/helm-secrets/wiki/Security-in-shared-environments
  HELM_SECRETS_VALUES_ALLOW_SYMLINKS="false" \
  HELM_SECRETS_VALUES_ALLOW_PATH_TRAVERSAL="false" \
  # https://github.com/jkroepke/helm-secrets/wiki/ArgoCD-Integration#multi-source-application-support
  HELM_SECRETS_WRAPPER_ENABLED="true" \
  HELM_SECRETS_VALUES_ALLOW_ABSOLUTE_PATH="true" \
  HELM_PLUGINS="/gitops-tools/helm-plugins/" \
  HELM_SECRETS_CURL_PATH="/gitops-tools/curl" \
  HELM_SECRETS_SOPS_PATH="/gitops-tools/sops" \
  HELM_SECRETS_VALS_PATH="/gitops-tools/vals" \
  HELM_SECRETS_AGE_PATH="/gitops-tools/age" \
  HELM_SECRETS_KUBECTL_PATH="/gitops-tools/kubectl" \
  HELM_SECRETS_ALLOWED_BACKENDS="sops,vals" \
  HELM_SECRETS_IGNORE_MISSING_VALUES="false" \
  HELM_SECRETS_DECRYPT_SECRETS_IN_TMP_DIR="true" \
  HELM_SECRETS_DEBUG="false" \
  # Netrc file path for helm-secrets git authentication to access private repos
  # iirc, we cannot use relative path correctly (ex: ../../valus.yaml)
  # especially for local helm chart were deploying directly from our git repo
  # thats why we use .netrc method
  # ref: https://github.com/jkroepke/helm-secrets/wiki/Values
  NETRC="/.netrc" \
  # Environment variables for ksops and sops
  # ref: https://github.com/viaduct-ai/kustomize-sops/tree/master?tab=readme-ov-file#argocdgitops-operator-w-ksopsagekey-in-okd4ocp4
  XDG_CONFIG_HOME="/.config" \
  SOPS_AGE_KEY_FILE="/.config/sops/age/keys.txt" \
  PATH="/gitops-tools:$PATH" \
  DEBIAN_FRONTEND=noninteractive

USER root

# Install dependencies in a separate layer for better caching
RUN apt-get update && \
  apt-get install -y \
  wget \
  xz-utils && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create directories
RUN mkdir -p /gitops-tools/helm-plugins

SHELL ["bash", "-c"]

# Download binaries - each tool in separate layer for granular caching
# This allows rebuilds to skip unchanged tools
RUN set -exuo pipefail \
  && export CURL_ARCH=$(uname -m | sed -e 's/x86_64/x86_64/' -e 's/aarch64/aarch64/') \
  && wget -qO- "https://github.com/stunnel/static-curl/releases/download/${STATIC_CURL_VERSION}/curl-linux-${CURL_ARCH}-musl-${STATIC_CURL_VERSION}.tar.xz" | tar -xJf- -C "${HELM_SECRETS_CURL_PATH%/*}" curl \
  && chmod +x "${HELM_SECRETS_CURL_PATH}"

RUN set -exuo pipefail \
  && export GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') \
  && wget -qO "${HELM_SECRETS_KUBECTL_PATH}" "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${GO_ARCH}/kubectl" \
  && chmod +x "${HELM_SECRETS_KUBECTL_PATH}"

RUN set -exuo pipefail \
  && export GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') \
  && wget -qO "${HELM_SECRETS_SOPS_PATH}" "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${GO_ARCH}" \
  && chmod +x "${HELM_SECRETS_SOPS_PATH}"

RUN set -exuo pipefail \
  && export GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') \
  && wget -qO- "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_${GO_ARCH}.tar.gz" | tar zxv -C "${HELM_SECRETS_VALS_PATH%/*}" vals \
  && chmod +x "${HELM_SECRETS_VALS_PATH}"

RUN set -exuo pipefail \
  && wget -qO- "https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz" | tar -C "${HELM_PLUGINS}" -xzf-

RUN set -exuo pipefail \
  && export GO_ARCH=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/') \
  && wget -qO- "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-${GO_ARCH}.tar.gz" | tar -xzf- --strip-components=1 -C "${HELM_SECRETS_AGE_PATH%/*}" age/age \
  && chmod +x "${HELM_SECRETS_AGE_PATH}"

# Create helm wrapper symlink
RUN ln -sf "${HELM_PLUGINS}/helm-secrets/scripts/wrapper/helm.sh" /usr/local/sbin/helm

COPY --from=ksops --chown=argocd:argocd /usr/local/bin/ksops /gitops-tools/ksops
COPY --from=ksops --chown=argocd:argocd /usr/local/bin/kustomize-sops /gitops-tools/kustomize-sops
COPY --from=ksops --chown=argocd:argocd /usr/local/bin/kustomize /gitops-tools/kustomize

# Use numeric UID instead of username to support runAsNonRoot security contexts
# The argocd user in the base image has UID 999
# ref: https://github.com/argoproj/argo-cd/blob/master/Dockerfile#L151
ENV ARGOCD_USER_ID=999
USER $ARGOCD_USER_ID
