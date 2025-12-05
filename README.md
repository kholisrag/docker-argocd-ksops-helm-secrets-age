# Docker ArgoCD + ksops + helm-secrets + age

This Docker Image is designed to facilitate the use of ArgoCD with ksops, helm-secrets, and age for managing Kubernetes deployments with encrypted secrets on both kustomize + helm methods.

## Tools Included

- argocd (main tool)
- ksops
- helm-secrets
- age (for encryption/decryption)
- kubectl
- helm
- kustomize

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
- `sha-{commit}` - Specific commit builds
- `{argocd_version}_{build_version}_{sha}` - Full version info tags

## Security & Supply Chain

All images include:

- ✅ **SBOM (Software Bill of Materials)** - Attestations included
- ✅ **Provenance** - Build provenance with mode=max
- ✅ **Multi-arch Support** - linux/amd64 and linux/arm64

## CI/CD Workflows

This repository uses GitHub Actions for automated building, testing, and releasing. See [`.github/workflows`](.github/workflows) for details.

### Key Features

- **Automated Security Scanning** - Trivy scans all builds
- **Conventional Commits** - PR validation and automatic versioning
- **Release Automation** - Automatic changelog generation
- **Multi-Registry Publishing** - Docker Hub, GHCR, Quay.io
- **Build Revisions** - Customizable build versions (0, 1, 2, -rc1, -beta1, etc.)
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

2. Run the sync workflow to update Dockerfile, or manually update ARG declarations in `Dockerfile`

## Contributing

When contributing, please follow [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles:

```text
type(scope): description

Examples:
- feat(api): add new authentication endpoint
- fix: resolve memory leak in controller
- docs: update installation instructions
```

This enables automatic versioning and changelog generation.
