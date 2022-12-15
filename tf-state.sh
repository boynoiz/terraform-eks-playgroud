#!/usr/bin/env bash
S3_BUCKET_NAME="pattp-tf-state"
AWS_REGION="ap-southeast-1"

aws s3api create-bucket \
	--region "${AWS_REGION}" \
	--create-bucket-configuration LocationConstraint="${AWS_REGION}" \
	--bucket "${S3_BUCKET_NAME}"

aws dynamodb create-table \
	--region "${AWS_REGION}" \
	--table-name terraform_locks \
	--attribute-definitions AttributeName=LockID,AttributeType=S \
	--key-schema AttributeName=LockID,KeyType=HASH \
	--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
