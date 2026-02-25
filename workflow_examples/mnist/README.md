# MNIST

A workflow example for distributed data processing, distributed model training, and retraining triggers based on metrics collection.

1. Populate MinIO with file `populate.py` in `workflow_examples/mnist/populate_minio/` (Change IP endpoint of MinIO in the script).
2. Run the workflow with Flyte CLI from `workflow_examples/mnist/` directory:
    ```bash
    pyflyte run --remote --env SYSTEM_IP=$(hostname -I | awk '{print $1}') --image copandrej/flyte_workflow:9 wf.py mnist_train
    ```
3. Monitor the progress on dashboards.


This workflow also serves as a template for other AI/ML workflows. Adjust the tasks, steps and code to integrate your own AI/ML workflow in to Self-Evolving AI/ML Workflow system.
