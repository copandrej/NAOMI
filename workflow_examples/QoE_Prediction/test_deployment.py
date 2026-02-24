import logging
import requests
from flytekit import task
import os


from .create_features import get_pod_template

# Get system ip from container environment variable set with pyflyte --env SYSTEM_IP=xxx
SYSTEM_IP = os.environ.get('SYSTEM_IP')

@task(pod_template=get_pod_template())
def test_deploy() -> None:
    data = {
        "signature_name": "serving_default",
        "instances":
            [[[2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56],
            [2.56, 2.56]]]
    }


    response = requests.post(f"http://{SYSTEM_IP}:30003/qoe/", json=data)
    response_json = response.json()
    logging.info(response_json)
    print(response_json)
