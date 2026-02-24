#!/bin/bash
set -e


# delete existing cluster if exists
if kind get clusters 2>/dev/null | grep -q "naomi-kind"; then
  echo "Kind cluster 'naomi-kind' already exists. Deleting it..."
  kind delete cluster --name naomi-kind
fi


# Create Kind cluster with all necessary NodePort mappings
kind create cluster --name naomi-kind --config=- <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  # Minio
  - containerPort: 30085
    hostPort: 30085
    protocol: TCP
    listenAddress: "0.0.0.0"
  - containerPort: 30090
    hostPort: 30090
    protocol: TCP
    listenAddress: "0.0.0.0"
  # MLFlow
  - containerPort: 31007
    hostPort: 31007
    protocol: TCP
    listenAddress: "0.0.0.0"
  # Ray
  - containerPort: 30001
    hostPort: 30001
    protocol: TCP
    listenAddress: "0.0.0.0"
  - containerPort: 30265
    hostPort: 30265
    protocol: TCP
    listenAddress: "0.0.0.0"
  - containerPort: 30003
    hostPort: 30003
    protocol: TCP
    listenAddress: "0.0.0.0"
  # Prometheus/Grafana
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
    listenAddress: "0.0.0.0"
  - containerPort: 30002
    hostPort: 30002
    protocol: TCP
    listenAddress: "0.0.0.0"
  # Flyte
  - containerPort: 31081
    hostPort: 31081
    protocol: TCP
    listenAddress: "0.0.0.0"
  - containerPort: 31082
    hostPort: 31082
    protocol: TCP
    listenAddress: "0.0.0.0"
  - containerPort: 31083
    hostPort: 31083
    protocol: TCP
    listenAddress: "0.0.0.0"
EOF


# Storage name overwrite for kind 
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: microk8s-hostpath
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
EOF


# Prepare NAOMI values
HOST_IP=$(hostname -I | awk '{print $1}')
cat <<EOF > values-kind.yaml
general:
  ip: "$HOST_IP"

workerGroups:
  amdGroup:
    replicas: 1
    minReplicas: 1
    maxReplicas: 1
    rayStartParams:
      numCpus: "1"
    container:
      resources:
        limits:
          cpu: "1"
          memory: "4G"
        requests:
          cpu: "1"
          memory: "4G"


flyte-binary:
  configuration:
    storage:
      providerConfig:
        s3:
          endpoint: "http://$HOST_IP:30085"
    inline:
      plugins:
        k8s:
          default-env-vars:
            - FLYTE_AWS_ENDPOINT: "http://$HOST_IP:30085"
       
minio:
  enabled: true
     
kube-prometheus-stack:
  enabled: true
  grafana:
    grafana.ini:
      auth.anonymous:
        enabled: true
EOF

# Install NAOMI-0.4.0 with a Helm command in a namespace called "project"
helm repo add naomi_charts https://copandrej.github.io/NAOMI/
helm repo update
helm install naomi naomi_charts/NAOMI --version 0.4.0 --values values-kind.yaml -n project --create-namespace

rm values-kind.yaml
echo "✅ NAOMI deployment is in progress. This will take a few minutes. You can check the status of the pods with: kubectl get pods -n project -w"
echo "Dashboards are available at:"
echo "Ray: http://$HOST_IP:30265/"
echo "Flyte: http://$HOST_IP:31082/"
echo "MinIO: http://$HOST_IP:30090/"
echo "Grafana: http://$HOST_IP:30000/"
echo "MLflow: http://$HOST_IP:31007/#/models"
