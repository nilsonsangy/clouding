# Clouding Lab AWS Environment Runbook

## ECR + ECS Fargate Workflow

Use the CloudFormation template `ecs-fargate.yml` (ECS Fargate) as the canonical AWS deployment path.

1. Build and push the application images to Amazon ECR.

   ```powershell
   $env:AWS_REGION = 'us-east-1'
   $env:AWS_ACCOUNT_ID = '000000000000'
   $env:AWS_ECR_REGISTRY = "$($env:AWS_ACCOUNT_ID).dkr.ecr.$($env:AWS_REGION).amazonaws.com"
   $env:IMAGE_TAG = 'latest'

   aws sts get-caller-identity

    aws ecr create-repository --repository-name clouding-users --region $env:AWS_REGION
    aws ecr create-repository --repository-name clouding-orders --region $env:AWS_REGION
    aws ecr create-repository --repository-name clouding-catalog --region $env:AWS_REGION
    aws ecr create-repository --repository-name clouding-frontend --region $env:AWS_REGION

   aws ecr get-login-password --region $env:AWS_REGION | docker login --username AWS --password-stdin $env:AWS_ECR_REGISTRY

   docker build -t clouding-users:$env:IMAGE_TAG app/users
   docker build -t clouding-orders:$env:IMAGE_TAG app/orders
   docker build -t clouding-catalog:$env:IMAGE_TAG app/catalog
   docker build -t clouding-frontend:$env:IMAGE_TAG app/frontend

   docker tag clouding-users:$env:IMAGE_TAG $env:AWS_ECR_REGISTRY/clouding-users:$env:IMAGE_TAG
   docker tag clouding-orders:$env:IMAGE_TAG $env:AWS_ECR_REGISTRY/clouding-orders:$env:IMAGE_TAG
   docker tag clouding-catalog:$env:IMAGE_TAG $env:AWS_ECR_REGISTRY/clouding-catalog:$env:IMAGE_TAG
   docker tag clouding-frontend:$env:IMAGE_TAG $env:AWS_ECR_REGISTRY/clouding-frontend:$env:IMAGE_TAG

   docker push $env:AWS_ECR_REGISTRY/clouding-users:$env:IMAGE_TAG
   docker push $env:AWS_ECR_REGISTRY/clouding-orders:$env:IMAGE_TAG
   docker push $env:AWS_ECR_REGISTRY/clouding-catalog:$env:IMAGE_TAG
   docker push $env:AWS_ECR_REGISTRY/clouding-frontend:$env:IMAGE_TAG
   ```

   Run the repository creation commands once per AWS account and region before the first push. After that, only the `docker push` commands are needed for new image versions.

   If `aws sts get-caller-identity` returns your account and user or role, your AWS authentication is working. If it fails, fix the AWS CLI credentials before trying to log in to ECR.

2. Define and deploy the ECS Fargate Infrastructure.
   Instead of running ECS commands manually, we provide a pre-built CloudFormation template (`aws/ecs-fargate.yml`) that creates the ECS cluster, Fargate capacities, networking, and the 4 services mapped to your ECR images.

   ```powershell
   aws cloudformation deploy `
     --template-file aws/ecs-fargate.yml `
     --stack-name clouding-lab `
     --parameter-overrides EcrRegistry=$env:AWS_ECR_REGISTRY ImageTag=$env:IMAGE_TAG `
     --capabilities CAPABILITY_IAM `
     --region $env:AWS_REGION
   ```

3. Deploy new image versions after each push (Optional for future updates).
   The CloudFormation template configures the initial deployment. If you push new images later, run:

   ```powershell
   aws ecs update-service --cluster clouding-lab --service users --force-new-deployment --region $env:AWS_REGION | Out-Null
   aws ecs update-service --cluster clouding-lab --service orders --force-new-deployment --region $env:AWS_REGION | Out-Null
   aws ecs update-service --cluster clouding-lab --service catalog --force-new-deployment --region $env:AWS_REGION | Out-Null
   aws ecs update-service --cluster clouding-lab --service frontend --force-new-deployment --region $env:AWS_REGION | Out-Null
   ```

4. Validate the application.
   Get the public IP of the frontend service automatically assigned by Fargate:

   ```powershell
   $TASK_ARN = aws ecs list-tasks --cluster clouding-lab --service-name frontend --region $env:AWS_REGION --query "taskArns[0]" --output text
   $ENI_ID = aws ecs describe-tasks --cluster clouding-lab --tasks $TASK_ARN --region $env:AWS_REGION --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value | [0]" --output text
   $FRONTEND_IP = aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --region $env:AWS_REGION --query "NetworkInterfaces[0].Association.PublicIp" --output text
   
   Write-Host "Frontend is running at http://$FRONTEND_IP"
   ```

5. When you finish the lab, delete the CloudFormation stack and the ECR repositories to avoid ongoing AWS charges.

    ```powershell
    aws cloudformation delete-stack --stack-name clouding-lab --region $env:AWS_REGION
    aws cloudformation wait stack-delete-complete --stack-name clouding-lab --region $env:AWS_REGION
    aws ecr delete-repository --repository-name clouding-users --force --region $env:AWS_REGION
    aws ecr delete-repository --repository-name clouding-orders --force --region $env:AWS_REGION
    aws ecr delete-repository --repository-name clouding-catalog --force --region $env:AWS_REGION
    aws ecr delete-repository --repository-name clouding-frontend --force --region $env:AWS_REGION
    ```

## Kubernetes Workflow

1. Use EKS or another managed Kubernetes cluster and configure `kubectl`.

2. Make sure the cluster can pull from ECR.
   - EKS nodes usually get this through the node IAM role.
   - If needed, create an `imagePullSecret` or attach the correct role first.

3. Apply the namespace and application manifests.

```bash
kubectl apply -f aws/k8s/namespace.yaml
kubectl apply -f aws/k8s/
```

4. Apply the observability stack.

```bash
kubectl apply -f aws/k8s/observability.yaml
```

5. Verify the workloads.

```bash
kubectl get namespace clouding-lab
kubectl get pods -n clouding-lab
kubectl get svc -n clouding-lab
kubectl get ingress -n clouding-lab
```

6. Expose the app.
   - The ingress host is `aws.clouding.example`.
   - Point DNS to the ingress controller or load balancer.
   - If you use an AWS load balancer, install the corresponding ingress controller first.

7. Confirm health and telemetry.
   - Frontend should answer through the ingress endpoint.
   - `users`, `orders`, and `catalog` should be healthy inside the cluster.
   - Prometheus, Grafana, and Jaeger should be reachable through the observability services.
