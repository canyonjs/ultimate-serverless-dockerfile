# ultimate-serverless-dockerfile
This Dockerfile is capable of building a container image for use with AWS Lambda, Azure Functions, or Google Cloud Run. It may be useful if you are interested in packaging the same application for deployment on multiple cloud providers FaaS offerings.

The Dockerfile expresses multiple conditional build pathways and the build path taken is defined by the build arguments passed. This technique relies on BuildKit to skip the unused branches (available in Docker engine > 23.0.  

For each platform, the following languages and runtimes are supported:

## Supported Platforms and Runtimes
### AWS Lambda
- Python
- Node.js
- Typescript
- Java
- Ruby
- Go (TODO)
- Rust (TODO)

### Azure Functions (TODO)
### Google Cloud Run (TODO)

## Getting Started
...
