# aws_lambda
Repo for developing Python3-based AWS Lambda code


Rough commands:
```bash
# Used hardcode paths with the ARG for convenience.
scp -r testcontrol1:/home/ubuntu/aws_lambda . 
docker buildx build --tag gwright99/lambda_py3.11:base .
docker run --rm gwright99/lambda_py3.11:base
```