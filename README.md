# aws-app-runner
Deploy a simple stack with aws app runner

Before deploying your ecr and app-runner you have verify that the service role `role/service-role/AppRunnerECRAccessRole` exist. (https://docs.aws.amazon.com/apprunner/latest/dg/security_iam_service-with-iam.html#security_iam_service-with-iam-roles)

## How to deploy

1. Change the `$ACCOUNT_ID` value with your in the file [account.hcl](https://github.com/julienpierini/aws-app-runner/blob/main/aws/live/account.hcl)
2. Go into the [dev](https://github.com/julienpierini/aws-app-runner/tree/main/aws/live/eu-west-1/dev) folder
3. init and deploy the vpc stack
```
$ cd vpc
$ terragrunt init
$ terragrunt apply
```
4. init and deploy the kms stack
```
$ cd ../kms
$ terragrunt init
$ terragrunt apply
```
4. init and deploy the ecr stack
```
$ cd ../ecr
$ terragrunt init
$ terragrunt apply
```
5. Push your image into ecr, follow [How to push an image to the ecr repository](https://github.com/julienpierini/aws-app-runner/edit/main/README.md#how-to-push-an-image-to-the-ecr-repository)
6. init and deploy the app-runner stack (edit the [app-runner vars](https://github.com/julienpierini/aws-app-runner/blob/main/aws/live/eu-west-1/dev/vars/app-runner.hcl) if needed)
```
$ vim ../vars/app-runner.hcl
$ cd ../app-runner
$ terragrunt init
$ terragrunt apply
```

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
