#!/bin/bash

AWS_ACCOUNT_ID="997817439961"
AWS_DEFAULT_REGION="ap-south-1" 
IMAGE_REPO_NAME="sahil-demo"
IMAGE_TAG="prod-img_${GIT_COMMIT}"
CLUSTER_NAME="Production-Cluster"
SERVICE_NAME="Prod-Service"
TASK_DEFINITION_NAME="Production"
DESIRED_COUNT="1"
ECR_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"

# login in to aws ecr
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 997817439961.dkr.ecr.ap-south-1.amazonaws.com

# build new image
docker build -t ${IMAGE_TAG} .

# tag image
#docker tag ${IMAGE_TAG}:latest 997817439961.dkr.ecr.ap-south-1.amazonaws.com/sahil-demo:${IMAGE_TAG}
docker tag ${IMAGE_TAG}:latest ${ECR_IMAGE}

# push image in aws ecr
#docker push 997817439961.dkr.ecr.ap-south-1.amazonaws.com/sahil-demo:${IMAGE_TAG}
docker push ${ECR_IMAGE}

# get role arn store in variable 
ROLE_ARN=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.executionRoleArn`

# get family store in variable 
FAMILY=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.family`
#echo "FAMILY= " $FAMILY

# get name arn store in variable 
NAME=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.containerDefinitions[].name`
#echo "NAME= " $NAME

# find and replace some content in task-definition file
sed -i "s#BUILD_NUMBER#$ECR_IMAGE#g" task-definition.json
sed -i "s#REPOSITORY_URI#$REPOSITORY_URI#g" task-definition.json
sed -i "s#ROLE_ARN#$ROLE_ARN#g" task-definition.json
sed -i "s#FAMILY#$FAMILY#g" task-definition.json
sed -i "s#NAME#$NAME#g" task-definition.json

# Get task definition from the aws console
TASK_DEF_REVISION=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.revision`

TASK_DEF_REVISION=$((TASK_DEF_REVISION-4))

cat task-definition.json

# register new task definition from new generated task definition file
aws ecs register-task-definition --cli-input-json file://task-definition.json --region="${AWS_DEFAULT_REGION}"

if [ $TASK_DEF_REVISION>0 ]
then
	# deregister previous task definiiton
	aws ecs deregister-task-definition --region ap-south-1 --task-definition Production:${TASK_DEF_REVISION}
fi

# update servise
aws ecs update-service --region ap-south-1 --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --task-definition "${TASK_DEFINITION_NAME}" --force-new-deployment 

