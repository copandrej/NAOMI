# NAOMI: Network AI Workflow Democratization

NAOMI is a production MLOps solution designed for deployment on a heterogeneous Kubernetes cluster.

The system uses the Ray framework for data processing, model training, and inference, distributing the computational load across nodes.
Data preparation is done using Pandas or Ray Data, with Minio as an object store.
Model training supports Keras, TensorFlow, and PyTorch, and is managed by Ray. 

MLflow handles model storage and management, while trained models are deployed as inference API endpoints using Ray Serve or as Kubernetes deployments.
Flyte orchestrates AI/ML workflows for retraining and redeployment of models, with retraining triggers based on monitored metrics. 
System monitoring is provided by Prometheus and Grafana. 

Developers register workflows with Flyte and monitor the system, while users can trigger workflows, monitor progress, and access models in MLflow. 
The system is designed to run autonomously, delivering efficient production AI/ML workflows. 
It is modular and can be adjusted to different use cases and requirements.

## Deployment

### Installation video

[![NAOMI MLOps Deployment Guide - Hands-On, Step-by-Step](https://img.youtube.com/vi/mA-iHkjI4GY/hqdefault.jpg)](https://www.youtube.com/watch?v=mA-iHkjI4GY)

#### Minimal requirements
- 12 CPU cores
- 32GB RAM
- 100GB Available disk space

#### 1. Kubernetes cluster 
Skip this step if you already have a kubernetes cluster with required addons.
- Install microk8s with addons: `dns`, `storage`, or run install script `./helper_scripts/system-install.sh`

- (Optional) Run install script `./helper_scripts/rasp-install.sh` on any raspberry pi node you want to join to the cluster.
- (Optional) Ansible playbook for installing microk8s on multiple nodes: `./helper_scripts/microk8s_ansible/` (requires ssh access and ansible)

**NAOMI can also be deployed on k3s**. In this case run install script `./helper_scripts/NAOMI-on-k3s.sh`, which adjusts k3s configurations to be compatible with NAOMI. 

#### 2. AI/ML workflow system
- Adjust configs in `values_example.yaml`, then deploy with helm:

```bash
helm repo add naomi_charts https://copandrej.github.io/NAOMI/
helm install naomi naomi_charts/NAOMI --version 0.4.0 --values values_example.yaml -n your_namespace
```


#### 3. Environment
This step is only required for running example AI/ML workflows.
The project uses [uv](https://docs.astral.sh/uv/) for dependency management. Install uv and sync dependencies:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv sync
```
Then connect flytectl to the cluster:
```bash
curl -sL https://ctl.flyte.org/install | sudo bash -s -- -b /usr/local/bin
flytectl config init --host=<CLUSTER_IP>:31081 --console=<CLUSTER_IP>:31082 --insecure
```
Alternatively, run `./helper_scripts/env-prepare.sh`.

## Configurations

All configurations are set as helm values. Adjust configs in `values_example.yaml` and deploy with helm.
Documentation and all configurations can be found in `SEMR/helm_charts/values.yaml`.

Project is modular with 5 main components:
- AI/ML model store with **MLflow**
- Distributed computing and AI/ML training with **Ray**
- Workflow orchestration with **Flyte**
- Data storage with **MinIO**
- System monitoring with **Prometheus & Grafana**

All components can be disabled, enabled, and configured in the helm values.

## Usage

After the system is deployed, users can access the components through the following dashboards.
System should be deployed in a closed network as access to dashboards and APIs is not secured.

#### Dashboards
- Ray: `http://<node_ip>:30265/`
- Flyte: `http://<node_ip>:31082/`
- MinIO: `http://<node_ip>:30090/`
- Grafana: `http://<node_ip>:30000/`
- MLflow: `http://<node_ip>:31007/#/models`

Components can be used separately or together to create AI/ML workflows.
To utilize MLflow model store users can use MLflow API on `http://<node_ip>:31007` (refer to MLflow documentation link: https://www.mlflow.org/docs/latest).
MinIO object store is accessible with default credentials `minio:miniostorage`.
Default grafana dashboard credentials are `admin:prom-operator`.
If required credentials can be changed in the helm values, other components and AI/ML workflow examples have to be updated with new credentials.
Ray cluster is a distributed computing framework and can be used with Ray API (https://docs.ray.io/en/master/index.html), refer to AI/ML workflow examples for how to send tasks to Ray cluster.
Flyte orchestrates AI/ML workflows. To create and run workflows refer to AI/ML workflow examples.


### AI/ML workflow examples

#### QoE prediction

Workflow example in `workflow_examples/qoe_prediction/`.

Quality of Experience (QoE) prediction is a workflow example adjusted from O-RAN SC AI/ML Framework use case https://docs.o-ran-sc.org/en/latest/projects.html#ai-ml-framework.

1. Populate MinIO with file `insert.py` in `workflow_examples/qoe_prediction/populate_minio/` (Change IP endpoint of MinIO in the script).
2. Run the workflow with Flyte CLI; --bt_s is batch size, --n is dataset size (1, 10, 100):
    ```bash
   pyflyte run --remote --env SYSTEM_IP=$(hostname -I | awk '{print $1}') --image copandrej/flyte_workflow:9 wf.py qoe_train --bt_s 10 --n 1
   ```
3. Monitor the progress on dashboards.

#### MNIST
A workflow example for distributed data processing, distributed model training, and retraining triggers based on metrics collection.
(It requires at least two Ray workers)

1. Populate MinIO with file `populate.py` in `workflow_examples/mnist/populate_minio/` (Change IP endpoint of MinIO in the script).
2. Run the workflow with Flyte CLI from `workflow_examples/mnist/` directory:
    ```bash
    pyflyte run --remote --env SYSTEM_IP=$(hostname -I | awk '{print $1}') --image copandrej/flyte_workflow:9 wf.py mnist_train

    ```
3. Monitor the progress on dashboards.

To schedule retraining based on cluster metrics...TO-DO

### Model deployment with SEMR_inference helm charts
This is a separate use case for deploying ML models as a service using SEMR_inference helm charts for models stored in MLflow. If using example AI/ML workflows, models are served as API endpoints using Ray Serve.
- Trained models are stored using MLFlow API.

```python
import mlflow

# SEMR's model store endpoint
os.environ['MLFLOW_TRACKING_URI'] = 'http://<System_IP>:31007'

# Log trained ML model to SEMR
mlflow.pytorch.log_model(model, "CNN_spectrum", registered_model_name="CNN_spectrum")
```

- Model inference service have to be containerized.
	- Docker image template has to be modified with code for model inference `docker_build/model_deployment/api-endpoint.py`.
	- Requirements for model inference have to be appended to requirements.txt and imported `docker_build/model_deployment/requirements.txt`.
	- Docker image has to be built and pushed to docker registry.

- ML Models as a Service can be instantiated and configured using helm values overrides, specifying model version, docker image, service port, number of replicas, and other configurations required by the service `helm_charts/SEMR_inference/values-overrides-*.yaml`.

- When a new model version is uploaded to MLflow, inference service can be re-instantiated using new configurations (values overrides). Docker images don't require any additional modification when models are retrained.

## Repository structure

`workflow_examples/`
Examples of full MLOps workflows for QoE prediction and MNIST classification.

`helper_scripts/`
Install & configure scripts for kubernetes, distributed clusters and setting up the environment.

`docker_build/`
Dockerfiles and scripts for building docker images for model deployment (`docker_build/model_deployment/`) and for Ray cluster (`docker_build/ray_image/`).
If the system is deployed on multi architecture cluster, docker images have to be built for each architecture.

`helm_charts/`
Helm charts SEMR and SEMR_inference. 
SEMR is the main system helm chart, SEMR_inference is for model deployment.
Helm charts repository is hosted on GitHub pages: https://copandrej.github.io/NAOMI/

`values_example.yaml`
Example of helm values file for configuring the system. 

## System architecture

![arch](fig/arch.png)

## User workflow diagrams

![arch](fig/actor_workflow_diag.png)

![arch](fig/all_actors_workflow_diag.png)

## License

This project is licensed under the [BSD-3 Clause License](LICENSE) - see the LICENSE file for details.


## Citation

Please cite our [paper](https://www.sciencedirect.com/science/article/pii/S1084804525000773) as follows:

```
@article{COP2025104180,
title = {An overview and solution for democratizing AI workflows at the network edge},
journal = {Journal of Network and Computer Applications},
volume = {239},
pages = {104180},
year = {2025},
issn = {1084-8045},
doi = {https://doi.org/10.1016/j.jnca.2025.104180},
url = {https://www.sciencedirect.com/science/article/pii/S1084804525000773},
author = {Andrej Čop and Blaž Bertalanič and Carolina Fortuna}
}
```


## Acknowledgment

The authors would like to acknowledge funding from the European Union's Horizon Europe Framework Programme [NANCY](https://nancy-project.eu/) project under Grant Agreement No. 101096456.

