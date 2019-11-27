# example-lambda-shell

Example for LambdaFunction(shellscript) +  awscli

## Getting Started

- lambdaのサンプルを実行する

### Prerequisites

docker , jq

### Installing & Usage

set up repository

```shell
git clone https://github.com/taguchi-so/example-lambda-shell.git
cd example-lambda-shell
make setup
make help
```

deploy lambda

```shell
make setup
make lambda-create LAMBDA_ROLE_ARN=*****
```

run lambda

```shell
make lambda-run

```

aws lambda delete-layer-version --layer-name awscli --version-number 3
