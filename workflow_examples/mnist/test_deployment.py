import logging
import os
import requests
from keras.datasets import mnist
from PIL import Image
from flytekit import task, PodTemplate
from kubernetes.client import V1PodSpec, V1Container, V1ResourceRequirements

from .fetch import get_pod_template

# Get system ip from container environment variable set with pyflyte --env SYSTEM_IP=xxx
SYSTEM_IP = os.environ.get('SYSTEM_IP')

@task(pod_template=get_pod_template())
def test_deploy() -> None:
    # Load the MNIST dataset and select an image
    img_array = mnist.load_data()[0][0][0]

    # Save the image to a file
    Image.fromarray(img_array).save('my.png')

    # Send a POST request with the image file
    with open("my.png", "rb") as image_file:
        response = requests.post(f"http://{SYSTEM_IP}:30003/mnist/", files={"file": image_file})

    # Log the response and check if the test passed
    response_json = response.json()
    logging.info(response_json)
    assert response_json["class_index"] == 5, "Test failed!"

    # Remove the image file
    os.remove('my.png')
