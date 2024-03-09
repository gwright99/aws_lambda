# Reference: https://github.com/seqeralabs/datasets-automation-blog/blob/master/Dockerfile
FROM debian:bookworm-slim

ARG LAMBDA_TASK_ROOT=/var/task

# Getting "This environment is externally managed" error when trying `pip3 install <PACKAGE>`
# https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN mkdir -p "${LAMBDA_TASK_ROOT}"
WORKDIR "${LAMBDA_TASK_ROOT}"

RUN apt update -y && \
    # apt upgrade -y && \ 
    apt install --no-install-recommends -y python3.11 python3-pip curl ca-certificates && \
    # Make the python3.11 executable available via python3
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    rm -rf /var/lib/apt/lists/*

# https://github.com/aws/aws-lambda-python-runtime-interface-client/?tab=readme-ov-file#usage
# Local testing: https://pypi.org/project/awslambdaric/
RUN mkdir -p aws-lambda-rie && \
    curl -Lo aws-lambda-rie/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie && \
    chmod +x aws-lambda-rie/aws-lambda-rie

COPY entry_script.sh .
COPY requirements.txt .
COPY app.py "${LAMBDA_TASK_ROOT}"

RUN pip3 install -r requirements.txt --target . && \
    chmod +x entry_script.sh

ENTRYPOINT [ "./entry_script.sh" ]
CMD [ "app.handler" ]