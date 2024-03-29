#!/bin/sh

# References: 
#  - https://docs.aws.amazon.com/lambda/latest/dg/images-test.html
#  - https://github.com/seqeralabs/datasets-automation-blog/blob/master/entry_script.sh

### BACKUP OF WHAT (Mostly WORKeD)
# if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
#   # exec /usr/local/bin/aws-lambda-rie-x86_64 /usr/bin/python3 -m awslambdaric "$@"

#   # Trying this since it seems cleaner than messing around with k8s init
#   git clone "https://$CR_USER:$CR_PAT@github.com/gwright99/aws_lambda.git" /app
#   chmod +x /app/entry_script.sh
#   mv /app/* /var/task

#   # Cant volume mount the GH repo from initcontainer in K8s if I have no repo stuff stored in here. Move RIE elsewhere.
#   # exec /var/task/aws-lambda-rie/aws-lambda-rie /usr/bin/python3 -m awslambdaric "$@"
#    exec /aws-lambda-rie/aws-lambda-rie /usr/bin/python3 -m awslambdaric "$@"
# else
#   exec /usr/bin/python3 -m awslambdaric "$@"
# fi


if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
  # exec /usr/local/bin/aws-lambda-rie-x86_64 /usr/bin/python3 -m awslambdaric "$@"

  # Trying this since it seems cleaner than messing around with k8s init
  git clone "https://$CR_USER:$CR_PAT@github.com/gwright99/aws_lambda.git" /aws_lambda
  #chmod +x /app/entry_script.sh
  #mv /app/$APP_NAME/* /var/task
  ROOT=/aws_lambda/apps/
  chmod +x $ROOT/core/entry_script.sh
  mv $ROOT/$APP_NAME/* /var/task

  # Cant volume mount the GH repo from initcontainer in K8s if I have no repo stuff stored in here. Move RIE elsewhere.
  # exec /var/task/aws-lambda-rie/aws-lambda-rie /usr/bin/python3 -m awslambdaric "$@"
   exec /aws-lambda-rie/aws-lambda-rie /usr/bin/python3 -m awslambdaric "$@"
else
  exec /usr/bin/python3 -m awslambdaric "$@"
fi