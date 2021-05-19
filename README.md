# Prerequisites
1. Create new AWS cluster with TMC
2. Copy/Download Access Key for Cluster and add in /config/kube.conf - This file will automatically be added to container when built
3. NOTE - AWS K8s clusters deployed by TMC require some additional RBAC bindings to allow priv pod deployments. Make sure to bind the appropriate group/user for your token. (replace with your group/service account values)
```
kubectl create clusterrolebinding privileged-cluster-role-binding --clusterrole=vmware-system-tmc-psp-privileged <group/service-acct>
```

# Building and Running the Local Management Container
## Build Container
`make build`
## Rebuild Container
`make rebuild`
## Start and exec to the container
`make run`
## Join Running Container
`make join`
## Start an already built Local Management Container
`make start`
## Stop a running Local Management Container
`make stop`
# Connecting to AWS Cluster from Management Container

## If you dont have /config/kube.conf configured and built into the container you will need to authenticate with TMC.
1. Login to AWS Cluster with TMC cli
`tmc login`
2. When prompted enter TMC API Access Token, context name, log level, credential, region, ssh key information
3. If TMC authentication is successful you should be able to run 
`kubectl get pods -A`

## If you have /config/kube.conf configured and built into container then your ~/.kube/config file will be present already
1. Run a kubectl command like the following and TMC will prompt for your API Token
`kubectl get pods -A`
2. Enter your TMC API Token when prompted
`? API Token ****************************************************************`
3. Your current login context should be prepopulated - hit enter to continue
`? Login context name xxxxxxx-491d-4162-b9b6-e10dxxxxxxx`
4. TMC authentication should be successful, to test run
`kubectl get pods -A`