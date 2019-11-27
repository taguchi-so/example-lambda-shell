# Option
#===============================================================
OS                   := $(shell uname | tr A-Z a-z )
SHELL                := /bin/bash
LAMBDA_ROLE_ARN      :=

# Const
#===============================================================
name                 := example-lambda-shell
bin_dir              := bin
tmp_dir              := tmp
layer_name           := awscli
lambda_name          := lambda-awscli

# Task
#===============================================================

## 必要なツール類をセットアップします
setup:
	go get github.com/Songmu/make2help/cmd/make2help

## tmpとbinを削除します
clean:
	rm -fr ./$(bin_dir)/*
	rm -fr ./$(tmp_dir)/*

## layer.zipとpfunctuon.zipをbuildします
build: clean .layer-zip .function-zip

## layerを更新します。
layer-publish:
	aws lambda publish-layer-version --layer-name awscli --zip-file fileb://bin/layer.zip

## lambdaのfunctionを作成します
lambda-create: build layer-publish .set-layer-arn
	aws lambda create-function --function-name $(lambda_name) \
		--handler function.handler \
		--runtime provided \
		--role $(LAMBDA_ROLE_ARN)  \
		--timeout 60 \
		--zip-file fileb://bin/function.zip \
		--layers $(LAYER_ARN)

## lambdaのcodeを更新します
lambda-update: .set-layer-arn .function-zip
	aws lambda update-function-code --function-name $(lambda_name) \
		--zip-file fileb://$(bin_dir)/function.zip
	aws lambda update-function-configuration --function-name $(lambda_name) \
		--layers $(LAYER_ARN)

## lambdaを実行します
lambda-run:
	aws lambda invoke --function-name $(lambda_name) /dev/stdout

## ヘルプ
help:
	@make2help $(MAKEFILE_LIST)

# internal task
.awscli-build:
	docker build -t $(layer_name) .
	$(eval CID := $(shell docker create $(layer_name)))
	echo $(CID)
	docker cp $(CID):/tmp/.local/ $(tmp_dir)/awscli
	docker rm $(CID)

.layer-zip: .awscli-build
	rm -f $(bin_dir)/layer.zip
	find $(tmp_dir)/awscli -type d  -print0 | xargs -0 chmod 755
	find $(tmp_dir)/awscli -type f -print0 | xargs -0 chmod 644
	chmod 755 $(tmp_dir)/awscli/bin/aws
	chmod 755 $(tmp_dir)/awscli
	chmod 755 scripts/bootstrap
	cp scripts/bootstrap $(tmp_dir)/bootstrap
	cd $(tmp_dir) && zip -r ./layer.zip ./awscli ./bootstrap
	mv $(tmp_dir)/layer.zip $(bin_dir)/

.function-zip:
	rm -f $(bin_dir)/function.zip
	chmod 755 scripts/function.sh
	zip -j $(bin_dir)/function.zip scripts/function.sh

.set-layer-arn:
	$(eval LAYER_ARN := $(shell aws lambda list-layer-versions --layer-name=$(layer_name) | jq '.LayerVersions[0].LayerVersionArn'))

.PHONY: build clean help lambda-create lambda-run lambda-update layer-publish setup
.DEFAULT_GOAL := build


