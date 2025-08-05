# AI content generation website using Google Gemini

Simple AWS-based website meant to generate content using Google Gemini LLM

> [!CAUTION]
> This Terraform code creates public-facing website without any access restrictions. Deploy it with caution!

## Infrastructure

The cloud infrastructure is basically made up of two components at this moment:
- AWS S3 bucket hosting static website
- AWS Lambda function acting as backend service

## Pre-requisites

- An AWS account
- Set of AWS credentials
- Google Gemini API key

## How to build it

```terraform
terraform init
terraform plan
terraform apply -auto-approve
```

## How to destroy it

```terraform
terraform destroy -auto-approve
```

## Future development

- Authorization layer (e.g. AWS Cognito) to allow only authenticated users to make requests
- Database for request history
- Enhanced security for AWS Lambda function