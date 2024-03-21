# aws_lambda
Repo for developing Python3-based AWS Lambda code

## Decisions

1. I want to test locally in the k8s cluster but I don't want to constantly recreate images when code changes. If I was working with pure Docker, I could just do a volume mount live reload. With the pods, it's a bit harder. Decided to use two init pods to:
    1. Git pull the repository (with the updated code) into a temporary (shared) volume.
    2. Copy the original Python packages into the temporary (shared) volume.
    3. Mount the fully updated and complete volume into the original location on the final container.

Rough commands:
```bash
# Used hardcode paths with the ARG for convenience.
scp -r testcontrol1:/home/ubuntu/aws_lambda . 
docker buildx build --no-cache --tag gwright99/lambda_py3.11:base .
docker run --rm gwright99/lambda_py3.11:base

curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'
docker exec -it CONTAINER_NAME curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'

# K8s commands
kubectl create deployment lambda --image=gwright99/lambda_py3.11:base --port=8080 --dry-run=client -o yaml > lambda.yaml
kubectl expose deployment lambda --port=8080 --target-port=8080 --dry-run=client -o yaml >> lambda.yaml 

# From an NGINX pod
curl -XPOST "http://lambda:8080/2015-03-31/functions/function/invocations" -d '{}' --verbose
curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}' --verbose
curl -XPOST "https://lambda.grahamwrightk8s.net/2015-03-31/functions/function/invocations" -d '{}' --verbose

```

## Infrastructure

I wanted a true CICD where making a change to `app.py` would cause the fresh code to be deployed onto the K8s cluster immediately. Got this working based on the following (kinda kludgy) setup:

1. The ArgoCD Application pointing towards this repo watches for changes in the `/manifests` folder, but the code I'll be deploying is in the rest of the repository. To force the update:

    1. Create a git pre-commit hook in `.git/hooks/pre-commit`. **NOTE: ** I have to write it out here because there [doesn't seem to be a clean way to track the damn thing](https://stackoverflow.com/questions/427207/can-git-hook-scripts-be-managed-along-with-the-repository).
        ```bash
        #!/bin/bash
        # Update and add a file in the manifests folder to force ArgoCD Resource Hook to trigger
        echo $(date) > manifests/trigger_argo_refresh.yaml
        git add manifests/trigger_argo_refresh.yaml 
        ```

    2. Create an ArgoCD [Resource Hook](https://argo-cd.readthedocs.io/en/stable/user-guide/resource_hooks/) definition in `manifests/resource_hook.yaml`. This creates a Job which leverages a serviec account and purgescript (created in `manifests/sa_delete.yaml`) to query the K8s API and delete a pod with the name `lambda*`.

    3. Make a change to a file(s) in the repository, add, and commit. The updated `manifests/trigger_argo_refresh.yaml` will tag along for the ride.