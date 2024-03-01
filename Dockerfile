# This Dockerfile supports building Lambda container images for the following languages: Node.js, TypeScript, Python, Java, Ruby
ARG LAMBDA_LANGUAGE=python
ARG LAMBDA_LANGUAGE_VERSION=3.12
ARG LAMBDA_LANGUAGE_MODIFIER=0

FROM public.ecr.aws/lambda/${LAMBDA_LANGUAGE}:${LAMBDA_LANGUAGE_VERSION}

###########################################
# Python
###########################################
# TODO: Python builds presuppose existence of requirments.txt inside source dir
FROM base AS lambda-python-0
ADD ${SOURCE_DIR} ${LAMBDA_TASK_ROOT}
RUN pip3 install -r requirements.txt --target ${LAMBDA_TASK_ROOT}
###########################################

###########################################
# Node.js
###########################################
# TODO: Node.js builds presuppose src/src project structure, src/package.json and src/src/_dist/index.js artifact
FROM base AS lambda-nodejs-0
RUN cd "src/" && npm install --production && npm run build && mv "_dist/index.js" ${LAMBDA_TASK_ROOT}
###########################################

###########################################
# Typescript
###########################################
FROM base AS lambda-nodejs-1
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
FROM base AS lambda-java-0
COPY target/classes ${LAMBDA_TASK_ROOT}
COPY target/dependency/* ${LAMBDA_TASK_ROOT}/lib/

###########################################
# Ruby
###########################################
FROM base as lambda-ruby-0
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

FROM lambda-${LAMBDA_LANGUAGE}-${LAMBDA_LANGUAGE_MODIFIER} as post-build

# Set CMD using entrypoint override option in AWS 
CMD []