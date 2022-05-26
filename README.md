# aws-app-runner
Deploy a simple stack with aws app runner

Before deploying your ecr and app-runner you have verify that the service role `role/service-role/AppRunnerECRAccessRole` exist. (https://docs.aws.amazon.com/apprunner/latest/dg/security_iam_service-with-iam.html#security_iam_service-with-iam-roles)
## How to push an image to the ecr repository

Get your docker image:
```
$ docker pull kennethreitz/httpbin
```

Push your image to the ecr repository created by this project (change `$ACCOUNT_ID` with your value):
```
$ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com
```
```
$ docker tag kennethreitz/httpbin $ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/httpbin-poc-dev:$TAG_VERSION
```
