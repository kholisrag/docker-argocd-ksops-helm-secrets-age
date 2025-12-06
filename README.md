# Docker ArgoCD + ksops + helm-secrets + age

This Docker Image is designed to facilitate the use of ArgoCD with ksops + helm-secrets, with sops + age + vals for managing Kubernetes deployments with encrypted secrets on both kustomize + helm methods, so we can leverage the benefits of GitOps with ArgoCD on the Declarative approach with secrets encrypted in the respective git repository alongside the manifests.

## Tools Included

- [argocd](https://github.com/argoproj/argo-cd) (main tool)
- [ksops](https://github.com/viaduct-ai/kustomize-sops/)
- [helm-secrets](https://github.com/jkroepke/helm-secrets/)
- [sops](https://github.com/getsops/sops) (helper for ksops and helm-secrets)
- [age](https://github.com/FiloSottile/age) (for encryption/decryption)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) (kubernetes cli)
- [helm](https://helm.sh/)
- [kustomize](https://kubectl.docs.kubernetes.io/references/kustomize/)
- [vals](https://github.com/helmfile/vals)

## Image Registries

This image is available on multiple registries:

```bash
# Docker Hub
docker pull docker.io/kholisrag/argocd-ksops-helm-secrets:latest

# GitHub Container Registry
docker pull ghcr.io/kholisrag/argocd-ksops-helm-secrets:latest

# Quay.io
docker pull quay.io/kholisrag/argocd-ksops-helm-secrets:latest
```

## Image Tags

Images are tagged using a priority-based strategy:

- `latest` - Latest stable build from main branch
- `edge` - Latest development build from main branch
- `nightly` - Daily automated builds
- `v{version}` - Semantic versioned releases
- `v{version}-{commit}` - Versioned releases with commit hash (main builds)
- `sha-{commit}` - Specific commit builds

## CI/CD Workflows

This repository uses GitHub Actions for automated building, testing, and releasing. See [`.github/workflows`](.github/workflows) for details.

### Key Features

- **Automated Security Scanning** - Trivy scans all builds
- **Conventional Commits** - PR validation and automatic versioning
- **Release Automation** - Automatic changelog generation
- **Multi-Registry Publishing** - Docker Hub, GHCR, Quay.io
- **End-to-End Testing** - Validates image functionality post-build using [kind](https://kind.sigs.k8s.io/) + [argocd-deployment](./e2e/argocd/) + [tests-manifests](./e2e/tests/)
- **Build Revisions** - Customizable build versions (0, 1, 2, -rc1, -beta1, etc.) (Note: not yet end-to-end tested)
- **Local Testing** - Test workflows locally with nektos/act (NOTE: limited support / many known issues)

## Version Management

Tool versions are managed centrally in the `.tool-versions` file, which serves as the single source of truth for all tool versions used in this project.

### Updating Tool Versions

#### Method 1: Manual Update

1. Edit `.tool-versions` file:

   ```text
   age 1.2.1
   argocd 3.2.0
   helm-secrets 4.7.4
   ksops 4.3.3
   kubectl 1.34.1
   sops 3.11.0
   vals 0.42.6
   ```

#### Method 2: [Check Tools Version Action](./.github/workflows/check-tools-version.yaml)

1. This GitHub Action automatically checks for the latest versions of the tools defined in `.tool-versions` on a scheduled basis (daily at 01:00 UTC) or can be triggered manually via workflow dispatch.

## Contributing

When contributing, please follow [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles:

```text
type(scope): description

Examples:
- feat: add new encryption method
- fix: dockerfile wrong base image
- docs: update installation instructions
```

This enables automatic versioning and changelog generation.
