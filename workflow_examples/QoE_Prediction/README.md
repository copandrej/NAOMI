# QoE prediction

Quality of Experience (QoE) prediction is a workflow example adjusted from O-RAN SC AI/ML Framework use case https://docs.o-ran-sc.org/en/latest/projects.html#ai-ml-framework.

1. Populate MinIO with file `insert.py` in `workflow_examples/qoe_prediction/populate_minio/` (Change IP endpoint of MinIO in the script).
2. Run the workflow with Flyte CLI; --bt_s is batch size, --n is dataset size (1, 10, 100):
    ```bash
   pyflyte run --remote --env SYSTEM_IP=$(hostname -I | awk '{print $1}') --image copandrej/flyte_workflow:9 wf.py qoe_train --bt_s 10 --n 1
    ```
3. Monitor the progress on dashboards.


This workflow also serves as a template for other AI/ML workflows. Adjust the tasks, steps and code to integrate your own AI/ML workflow in to Self-Evolving AI/ML Workflow system.
