# Kubernetes Deployment

For Deployment to Kubernetes 3 services/servers are needed
- Mongo 3.0+ database
- [Poustaches] task execution service
- a microblog.pub instance

This documentation is for how to configure, set-up and deploy
microblog.pub to kubernetes

# Configuration

For configuration, inside the kubernetes folder of the repo there are two files:

- template-backend.yaml
- templace-microblogpub.yaml

these two provide templates that need to be edited to be ready for deployment.

Further, the Makefile may need some edits too, primarily being:

- Image Names to build to
- Container registry image name  to push the image to a CR when needed

## Backend

Pousstaches and MongoDB are setup as services/deployment inside the 
template_backend.yaml files. Copy these files to deploy-backend.yaml to utilize with the Makefile

## Frontend

Microblogpub has to built as a container, and for Kubernetes, requires a image from a container registry. Further, the configuration of the instance is handled by environment variables passed from some configmaps.
- server-config
- envvars

Server-config is mounted as a folder to the microblogpub instance with a
me,yml file. You can configure this yourself, or use the Setup Wizard generate file copy and pasted correctly into the configmap.

envvars overrides container environment variables defaults so can be edited also if you change your clusters network
between services.

# deployment keys

To deploy to a cluster, a ImagePullSecret will probably be needed (except if you publish the image for microblog.pub
publicly). In line with this [tutorial][github_container_key], a script has been made written to generate a yaml file
for kubernetes for Github container registry. to utilize:

```bash
python ./scri[ts/generate_registry_secret.py --user <your username here> --token <your PAT for github> \
  --type github --path ./kubeernetes/deploy/container-secrets.yaml
```

# Ingress

To access the cluster pods, a ingress must be isntalled, with Kind use NGINX:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```



[Poustaches]: https://github.com/tsileo/poussetaches
[github_container_key]: https://dev.to/asizikov/using-github-container-registry-with-kubernetes-38fb