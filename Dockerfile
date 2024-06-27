# Base image which includes runtime, usually provided by cloud provider
ARG BASE_IMAGE=public.ecr.aws/lambda/python:3.12

# Target cloud platform (aws, azure, gcp)
ARG TARGET_PLATFORM=aws

# Language of the function
ARG FUNCTION_LANGUAGE=python

# Location of the source code to be containerized
ARG SOURCE_CODE_DIR="examples/python/"

# Name of the file used as the function entrypoint
ARG MAIN_FILE_NAME="app"

# If you produce an artifact which needs to be included in the image, set this ARG
ARG ARTIFACT_DIR="dist/"

# Location the FaaS expects your code to be
ARG FUNCTION_ROOT="/var/task/"

FROM ${BASE_IMAGE} as base

###########################################
# AWS Lambda Python
###########################################
# Python builds presuppose existence of requirments.txt inside source dir
FROM base AS aws-python
ADD ${SOURCE_CODE_DIR} ${FUNCTION_ROOT}
RUN pip3 install -r requirements.txt --target ${FUNCTION_ROOT}
###########################################

###########################################
# AWS Lambda Node.js
###########################################
# TODO: If webpacking or similar bundling we don't need to include extra cruft, only artifact
FROM base AS aws-nodejs
ADD ${SOURCE_CODE_DIR} ${FUNCTION_ROOT}
RUN npm install --production && npm run build && mv "${ARTIFACT_DIR}${MAIN_FILE_NAME}.js" ${FUNCTION_ROOT}
###########################################

###########################################
# AWS Lambda Typescript
###########################################
FROM base AS aws-typescript
WORKDIR /usr/app
COPY package.json index.ts  ./
RUN npm install
RUN npm run build
WORKDIR ${FUNCTION_ROOT}
COPY /usr/app/dist/* ./
###########################################

###########################################
# AWS Lambda Java
###########################################
FROM base AS aws-java
COPY target/classes ${FUNCTION_ROOT}
COPY target/dependency/* ${FUNCTION_ROOT}/lib/

###########################################
# AWS Lambda Ruby
###########################################
FROM base as aws-ruby
# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ${FUNCTION_ROOT}/

# Install Bundler and the specified gems
RUN gem install bundler:2.4.20 && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install

# Copy function code
COPY lambda_function.rb ${FUNCTION_ROOT}/
###########################################

###########################################
# TODO: AWS Lambda Go
###########################################
###########################################
# TODO: AWS Lambda Rust
###########################################

FROM ${TARGET_PLAFORM}-${FUNCTION_LANGUAGE} as post-build

# Note: Due to limitations in interpolating variables inside of Dockerfile CMD instructions, this is hardcoded for now.
CMD [ "app.handler" ]
