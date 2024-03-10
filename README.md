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
curl "https://lambda.grahamwrightk8s.net/2015-03-31/functions/function/invocations" -d '{}'

```