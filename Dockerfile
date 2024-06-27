ARG BASE_IMAGE=public.ecr.aws/lambda/python:3.12
ARG TARGET_PLATFORM=aws
ARG FUNCTION_LANGUAGE=python
ARG SOURCE_CODE_DIR="src/"
ARG MAIN_FILE_NAME="index"
ARG ARTIFACT_DIR="_dist/"

FROM ${BASE_IMAGE} as base

###########################################
# AWS Lambda Python
###########################################
# Python builds presuppose existence of requirments.txt inside source dir
FROM base AS aws-python
ADD ${SOURCE_CODE_DIR} ${LAMBDA_TASK_ROOT}
RUN pip3 install -r requirements.txt --target ${LAMBDA_TASK_ROOT}
###########################################

###########################################
# Node.js
###########################################
# Node.js builds presuppose src/src project structure, src/package.json and src/src/_dist/index.js artifact
FROM base AS aws-nodejs
ADD ${SOURCE_CODE_DIR} ${LAMBDA_TASK_ROOT}
RUN npm install --production && npm run build && mv "${ARTIFACT_DIR}${MAIN_FILE_NAME}.js" ${LAMBDA_TASK_ROOT}
###########################################

###########################################
# Typescript
###########################################
FROM base AS aws-typescript
WORKDIR /usr/app
COPY package.json index.ts  ./
RUN npm install
RUN npm run build
WORKDIR ${LAMBDA_TASK_ROOT}
COPY /usr/app/dist/* ./
###########################################

###########################################
# Java
###########################################
FROM base AS aws-java
COPY target/classes ${LAMBDA_TASK_ROOT}
COPY target/dependency/* ${LAMBDA_TASK_ROOT}/lib/

###########################################
# Ruby
###########################################
FROM base as aws-ruby
# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ${LAMBDA_TASK_ROOT}/

# Install Bundler and the specified gems
RUN gem install bundler:2.4.20 && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install

# Copy function code
COPY lambda_function.rb ${LAMBDA_TASK_ROOT}/
###########################################

###########################################
# TODO: Go
###########################################
###########################################
# TODO: Rust
###########################################

FROM ${TARGET_PLAFORM}-${FUNCTION_LANGUAGE} as post-build

# Set CMD using entrypoint override option in AWS 
CMD []
