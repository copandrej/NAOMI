import os
import numpy as np
import requests
import logging

from flytekit import task
from kubernetes.client import V1ResourceRequirements, V1Container, V1PodSpec
from flytekit import PodTemplate


SYSTEM_IP = os.environ.get('SYSTEM_IP') or "127.0.0.1"


@task
def test_deploy() -> None:
    """
    Send a random image (96x96x3) to the Ray Serve endpoint
    and log the inference response.
    """
    random_image = np.random.rand(96, 96, 3).astype('float32')
    # For best results, scale to [-1..1] or something similar:
    random_image = (random_image - 0.5) * 2.0  # simple approach

    data = {
        "instances": [random_image.tolist()]  # shape (1, 96, 96, 3)
    }

    url = f"http://{SYSTEM_IP}:30003/VWW/"

    try:
        response = requests.post(url, json=data)
        response.raise_for_status()
        print("Inference response:", response.json())
        logging.info(f"Inference response: {response.json()}")
    except requests.RequestException as e:
        logging.error(f"Request failed: {str(e)}")
        raise e


if __name__ == "__main__":
    test_deploy()
