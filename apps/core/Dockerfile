# Reference: https://github.com/seqeralabs/datasets-automation-blog/blob/master/Dockerfile
FROM debian:bookworm-slim

ARG APP_NAME="core"
ARG PYTHON_REQUIREMENTS_ROOT=/tmp/requirements
ARG LAMBDA_TASK_ROOT=/var/task

# Getting "This environment is externally managed" error when trying `pip3 install <PACKAGE>`
# https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN mkdir -p "${LAMBDA_TASK_ROOT}" && mkdir -p "${PYTHON_REQUIREMENTS_ROOT}"
WORKDIR "${LAMBDA_TASK_ROOT}"

RUN apt update -y && \
    # apt upgrade -y && \ 
    apt install --no-install-recommends -y python3.11 python3-pip curl ca-certificates git && \
    # Make the python3.11 executable available via python3
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    rm -rf /var/lib/apt/lists/*

# https://github.com/aws/aws-lambda-python-runtime-interface-client/?tab=readme-ov-file#usage
# Local testing: https://pypi.org/project/awslambdaric/
# RUN mkdir -p aws-lambda-rie && \
#     curl -Lo aws-lambda-rie/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie && \
#     chmod +x aws-lambda-rie/aws-lambda-rie
RUN mkdir -p /aws-lambda-rie && \
    curl -Lo /aws-lambda-rie/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie && \
    chmod +x /aws-lambda-rie/aws-lambda-rie

# A bit janky but I think this works and is only minorly inefficient to alwasy get core but also app if specified.
# Wildcard on the end of the app file to handle scenarios where there is no file.
COPY core/entry_script.sh .
COPY ${APP_NAME}/entry_script.sh* .

COPY core/src/requirements.txt ${PYTHON_REQUIREMENTS_ROOT}/requirements-core.txt
COPY ${APP_NAME}/src/requirements.txt* ${PYTHON_REQUIREMENTS_ROOT}/requirements-${APP_NAME}.txt
# Ref: https://stackoverflow.com/questions/36744143/how-can-i-define-multiple-requirement-files
# RUN pip3 install -r requirements.txt && chmod +x entry_script.sh
RUN find ${PYTHON_REQUIREMENTS_ROOT} -name "requirement*" -type f -exec pip3 install -r '{}' ';' && chmod +x entry_script.sh

# To minimize the redownload of Python packages when all I've done is change application code.
COPY core/src/app.py "${LAMBDA_TASK_ROOT}"
COPY ${APP_NAME}/src/* "${LAMBDA_TASK_ROOT}"

# Hardcoding just to get it working.
ENTRYPOINT [ "/bin/bash", "/var/task/entry_script.sh" ]
CMD [ "app.handler" ]