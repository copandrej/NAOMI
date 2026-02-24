import logging
import requests
import os
import numpy as np
from flytekit import task

# Get system ip from container environment variable set with pyflyte --env SYSTEM_IP=xxx
SYSTEM_IP = os.environ.get('SYSTEM_IP')

@task
def test_deploy() -> None:
    """
    Test the deployed image classification model by sending a random image to the inference endpoint.
    """
    # Generate a single random "image" with shape (32,32,3)
    # We'll send it as a batch of 1, i.e. shape = (1, 32, 32, 3)
    random_image = np.random.rand(32, 32, 3).tolist()

    data = {
        "instances": [random_image]
    }

    url = f"http://{SYSTEM_IP}:30003/ImClass/"

    try:
        response = requests.post(url, json=data)
        response.raise_for_status()
        response_json = response.json()
        logging.info(f"Inference response: {response_json}")
        print("Inference response:", response_json)
    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {str(e)}")
        raise e

if __name__ == "__main__":
    test_deploy()