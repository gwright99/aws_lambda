#!/bin/sh

# References: 
#  - https://docs.aws.amazon.com/lambda/latest/dg/images-test.html
#  - https://github.com/seqeralabs/datasets-automation-blog/blob/master/entry_script.sh
if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  # exec /usr/local/bin/aws-lambda-rie-x86_64 /usr/bin/python3 -m awslambdaric "$@"
  exec /var/task/aws-lambda-rie/aws-lambda-rie /usr/bin/python3 -m awslambdaric "$@"
else
  exec /usr/bin/python3 -m awslambdaric "$@"
fi