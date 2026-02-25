# TinyML Image Classification

TinyML Image Classification is a workflow example adjusted from https://siliconlabs.github.io/mltk/docs/python_api/models/tinyml/image_classification.html and https://github.com/SiliconLabs/mltk/blob/master/mltk/models/tinyml/image_classification.py which is a simplified version of the MLPerf TinyML benchmark using the same model and dataset. 
MLPerf TinyML Benchmark: https://github.com/mlcommons/tiny/tree/master
Install silabs-mltk[full]==0.19.0 in your environment.

1. Run the workflow with Flyte CLI; --batch_size is batch size, --epochs is num of epochs to train:
    ```bash
   pyflyte run --remote --env SYSTEM_IP=$(hostname -I | awk '{print $1}') --image copandrej/flyte_workflow:9 workflow.py image_classification_workflow --batch_size 10 --epochs 1
    ```
2. Monitor the progress on dashboards.

This workflow also serves as a template for other AI/ML workflows. Adjust the tasks, steps and code to integrate your own AI/ML workflow in to Self-Evolving AI/ML Workflow system.
