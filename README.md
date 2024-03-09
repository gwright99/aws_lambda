# aws_lambda
Repo for developing Python3-based AWS Lambda code


Rough commands:
```bash
# Used hardcode paths with the ARG for convenience.
scp -r testcontrol1:/home/ubuntu/aws_lambda . 
docker buildx build --tag gwright99/lambda_py3.11:base .
docker run --rm gwright99/lambda_py3.11:base

curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'
docker exec -it CONTAINER_NAME curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'

# K8s commands
kubectl create deployment lambda --image=gwright99/lambda_py3.11:base --port=8080 --dry-run=client -o yaml > lambda.yaml
kubectl expose deployment lambda --port=8080 --target-port=8080 --dry-run=client -o yaml >> lambda.yaml 

# From an NGINX pod
curl -XPOST "http://lambda:8080/2015-03-31/functions/function/invocations" -d '{}'
curl "https://lambda.grahamwrightk8s.net/2015-03-31/functions/function/invocations" -d '{}'

```