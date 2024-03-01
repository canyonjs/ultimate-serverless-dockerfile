# multi-lambda-dockerfile
This Dockerfile is an example of using build arguments to create conditional build pathways, with each build branch representing a build sequence for a supported Lambda runtime language.


This technique relies on BuildKit to skip the unused branches.