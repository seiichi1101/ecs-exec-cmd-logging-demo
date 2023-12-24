include .env

PROJECT_NAME=ecs-exec-cmd-logging-demo
IMAGE_NAME=${PROJECT_NAME}-php-fpm
BUCKET_NAME=${PROJECT_NAME}-bucket
CLUSTER_NAME=SimpleECSCluster
SERVICE_NAME=SimpleECSService
COMMAND='/bin/sh'
DOCKER_IMAGE_TAG=latest
DOCKER_USERNAME=seiichi19881101


_connect-to-one-of-the-running-containers:
	@echo "Connecting to ${CONTAINER_NAME} container in ${CLUSTER_NAME} cluster Task ARN: ${TASK_ARN}"
	@aws ecs execute-command --cluster=${CLUSTER_NAME} --task=${TASK_ARN} --container=${CONTAINER_NAME} --interactive --command ${COMMAND}

execute-command-to-php-fpm-container:
	@TASK_ARN=$$(aws ecs list-tasks --cluster=${CLUSTER_NAME} --service ${SERVICE_NAME} --desired-status=RUNNING --output text --query 'taskArns[0]') && \
	make _connect-to-one-of-the-running-containers CLUSTER_NAME=${CLUSTER_NAME} TASK_ARN=$${TASK_ARN} CONTAINER_NAME="php-fpm-container" COMMAND="${COMMAND}"

docker-push:
	@docker build -t ${IMAGE_NAME} ./
	@docker tag ${IMAGE_NAME} ${DOCKER_USERNAME}/${IMAGE_NAME}:${DOCKER_IMAGE_TAG}
	@docker login -u ${DOCKER_USERNAME}
	@docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${DOCKER_IMAGE_TAG}

upload-cfn:
	@aws s3 cp ./template.yml s3://${BUCKET_NAME}/template.yml
