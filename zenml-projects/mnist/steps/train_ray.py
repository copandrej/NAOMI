import keras
from zenml import step, ArtifactConfig
import ray
from typing import Annotated
import numpy as np

@step()
def train(x_train: np.ndarray, y_train: np.ndarray) \
        -> Annotated[keras.Sequential, ArtifactConfig(name="mnist_model", is_model_artifact=True)]:
    @ray.remote(num_cpus=4)
    def remo_train(x, y):
        import keras
        from keras import layers
        ## Uncomment for mlflow logging, make sure mlflow server is running on this ip
        # import mlflow
        # import mlflow.keras
        # mlflow.set_tracking_uri("http://193.2.205.27:5000")
        # mlflow.set_experiment("mnist")
        # mlflow.autolog()

        num_classes = 10
        input_shape = (28, 28, 1)

        model = keras.Sequential(
            [
                keras.Input(shape=input_shape),
                layers.Conv2D(32, kernel_size=(3, 3), activation="relu"),
                layers.MaxPooling2D(pool_size=(2, 2)),
                layers.Conv2D(64, kernel_size=(3, 3), activation="relu"),
                layers.MaxPooling2D(pool_size=(2, 2)),
                layers.Flatten(),
                layers.Dropout(0.5),
                layers.Dense(num_classes, activation="softmax"),
            ]
        )

        model.summary()

        batch_size = 128
        epochs = 20
        model.compile(loss="categorical_crossentropy", optimizer="adam", metrics=["accuracy"])

        model.fit(x, y, batch_size=batch_size, epochs=epochs, validation_split=0.1)
        return model

    ray.init(address="ray://193.2.205.27:30001", ignore_reinit_error=True)

    model_uris = [remo_train.remote(x_train, y_train) for _ in range(3)]
    models = [ray.get(uri) for uri in model_uris]

    model_out = models[0]
    return model_out[0]
