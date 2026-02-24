# Start from the rayproject/2.54.0-py310-aarch64 image for raspberry pi

FROM rayproject/ray:2.54.0-py310

# Install dependencies from requirements.txt
COPY requirements.txt .
RUN pip install -r requirements.txt

# docker build . --tag copandrej/ijs-custom:ray-amd64-ray254
# docker build . --tag copandrej/ijs-custom:ray-aarch64-ray254 # on a raspberry pi