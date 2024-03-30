# aws_lambda
Repo for developing Python3-based AWS Lambda code

## Decisions

1. I want to test locally in the k8s cluster but I don't want to constantly recreate images when code changes. If I was working with pure Docker, I could just do a volume mount live reload. With the pods, it's a bit harder. Decided to use two init pods to:
    1. Git pull the repository (with the updated code) into a temporary (shared) volume.
    2. Copy the original Python packages into the temporary (shared) volume.
    3. Mount the fully updated and complete volume into the original location on the final container.

Rough commands:
```bash
$ scp -r testcontrol1:/home/ubuntu/aws_lambda . 
$ cd ~/aws_lambda/apps
$ docker buildx build --no-cache -f core/Dockerfile --tag gwright99/lambda_py3.11:base .
$ docker buildx build --no-cache -f core/Dockerfile --build-arg APP_NAME=app1 --tag gwright99/lambda_py3.11:base .
$ docker run -it --rm --entrypoint /bin/bash gwright99/lambda_py3.11:base

curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'
docker exec -it CONTAINER_NAME curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'

# K8s commands
kubectl create deployment lambda --image=gwright99/lambda_py3.11:base --port=8080 --dry-run=client -o yaml > lambda.yaml
kubectl expose deployment lambda --port=8080 --target-port=8080 --dry-run=client -o yaml >> lambda.yaml 

# From an NGINX pod
curl -XPOST "http://lambda:8080/2015-03-31/functions/function/invocations" -d '{}' --verbose
curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}' --verbose
curl -XPOST "https://lambda.grahamwrightk8s.net/2015-03-31/functions/function/invocations" -d '{}' --verbose

# Modified the HTTPRoute so that easy-to-remember URL is converted behind-the-scenes
curl -XPOST "https://lambda.grahamwrightk8s.net/app1" -d '{}' --verbose
curl -XPOST "https://lambda.grahamwrightk8s.net/app2" -d '{}' --verbose
```

## Infrastructure

I wanted a true CICD where making a change to `app.py` would cause the fresh code to be deployed onto the K8s cluster immediately. Got this working based on the following (kinda kludgy) setup:

1. The ArgoCD Application pointing towards this repo watches for changes in the `/manifests` folder, but the code I'll be deploying is in the rest of the repository. To force the update:

    1. Create a git pre-commit hook. 

        - Was originally in `.git/hooks/pre-commit` but this sucks you can't save changes made within the `.git` folder.
        - Swapped to a contollable [`.githook` bespoke folder](https://stackoverflow.com/questions/427207/can-git-hook-scripts-be-managed-along-with-the-repository)
        - Told project git to use the folder via: ` git config core.hooksPath .githooks`.
        - Configured dummy file to generate a small ConfigMap (seems to work equally well with just a timestamp in a file).

    2. Create an ArgoCD [Resource Hook](https://argo-cd.readthedocs.io/en/stable/user-guide/resource_hooks/).
    
        - Originally defined in `manifests/resource_hook.yaml`, but later split our 1-1 in the app subfolders for atomicity.
        - Creates a Job which runs a custom (janky) Bash script which kills the associated Pod.
        - Committing to git repo fires a webhook from Github -> ArgoCD. ArgoCD then syncs which prompts the activation of the Resource hook.

 
## App Usage and Gotchas

#### Adding a new app

    1. Clone an existing app folder in `apps`:

        ```bash
        $ cd <PATH_TO_PROJECT>/apps
        $ cp -r app1 new_app
        ```
    
    2. Add custom app logic in `<PATH_TO_PROJECT>/apps/<APP_NAME>>/src/app.py`.

    3. Update `<PATH_TO_PROJECT>/apps/<APP_NAME>/k8s_manifests`:
        - **manifest.yaml**
            Find/Replace `app1` with your desired name. For simplicity make sure `<APP_NAME>` is the same value as what you give to other replaced fields.

            Modify API Gateway allowed behaviours too.
    
        - **resource_hook_deletion.yaml**
            Find/Replace `app1` with your desired name. For simplicity make sure `<APP_NAME>` is the same value as what you give to other replaced fields.

            Replace the `generateName` value with something unique.

    4. Create a symlink in `<PATH_TO_PROJECT>/manifests` to `<PATH_TO_PROJECT/apps/<APP_NAME>/k8s_manifests/*`:

        - Keeps everything in a central location while getting the fails sorted locally in the app where they are used.

            ```bash
            $ cd <PATH_TO_PROJECT>/manifests
            $ ln -s ../apps/<APP_NAME>/k8s_manifests/manifest.yaml <APP_NAME>.yaml
            $ ln -s ../apps/<APP_NAME>/k8s_manifests/resource_hook_deletion.yaml <APP_NAME>_resource_hook_delete.yaml
            ```
    
    5. Modify code, make a commit, and see automation take over. ***Note: This assumes you did the work prior to setup the ArgoCD cluster, GH webhooks, K8s Pod design, etc.


#### Gotchas
    
    !!! warning "Some parts of this are brittle!"
    
        - `purgescript` often hangs when there is a single mistake in manifests (e.g. name with underscore rather than hyphens).
        - ArgoCD somethings wont synch because Jobs get stuff / not kicked off for parsing reasons.


