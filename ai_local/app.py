from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
import io

from inference import (
    load_classification_model,
    load_orientation_model,
    run_models,
    LEOPARD_CAT_THRESHOLD,
)


# ============================================================
# FLASK
# ============================================================

app = Flask(__name__)

CORS(app)


# ============================================================
# CONFIGURATION
# ============================================================

# Jika confidence orientation di bawah nilai ini,
# hasil dianggap tidak cukup yakin.
ORIENTATION_CONFIDENCE_THRESHOLD = 0.70


# ============================================================
# LOAD MODELS
# ============================================================

print()
print("=" * 70)
print("LEOPARD CAT AI API")
print("=" * 70)

print()
print("Loading classification model...")

(
    classification_model,
    classification_classes,
) = load_classification_model()


print()
print("Loading orientation model...")

(
    orientation_model,
    orientation_classes,
) = load_orientation_model()


print()
print("Semua model berhasil dimuat.")

print("=" * 70)


# ============================================================
# HOME
# ============================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "status": "success",
        "message": "Leopard Cat AI API is running",
        "classification_threshold":
            LEOPARD_CAT_THRESHOLD * 100,
        "orientation_confidence_threshold":
            ORIENTATION_CONFIDENCE_THRESHOLD * 100,
    })


# ============================================================
# PREDICT
# ============================================================

@app.route("/predict", methods=["POST"])
def predict():

    # --------------------------------------------------------
    # CHECK FILE
    # --------------------------------------------------------

    if "image" not in request.files:

        return jsonify({
            "status": "error",
            "error": "Tidak ada file image.",
        }), 400


    file = request.files["image"]


    if file.filename == "":

        return jsonify({
            "status": "error",
            "error": "Nama file kosong.",
        }), 400


    try:

        # ----------------------------------------------------
        # READ IMAGE
        # ----------------------------------------------------

        image_bytes = file.read()

        image = Image.open(
            io.BytesIO(image_bytes)
        ).convert("RGB")


        # ----------------------------------------------------
        # RUN CLASSIFICATION + ORIENTATION
        # ----------------------------------------------------

        result = run_models(
            classification_model,
            classification_classes,
            orientation_model,
            orientation_classes,
            image,
        )


        classification = (
            result["classification"]
        )

        orientation = (
            result["orientation"]
        )


        # ----------------------------------------------------
        # CLASSIFICATION VALUES
        # ----------------------------------------------------

        classification_label = (
            classification["label"]
        )

        classification_confidence = (
            classification["confidence"]
        )

        leopard_cat_probability = (
            classification[
                "leopard_cat_probability"
            ]
        )

        null_probability = (
            classification[
                "null_probability"
            ]
        )


        # ----------------------------------------------------
        # ORIENTATION VALUES
        # ----------------------------------------------------

        raw_orientation = (
            orientation["label"]
        )

        raw_orientation_confidence = (
            orientation["confidence"]
        )


        # ----------------------------------------------------
        # ORIENTATION CONFIDENCE FILTER
        # ----------------------------------------------------

        if (
            raw_orientation_confidence
            >= ORIENTATION_CONFIDENCE_THRESHOLD
        ):

            final_orientation = (
                raw_orientation
            )

            final_orientation_confidence = (
                raw_orientation_confidence
            )

        else:

            final_orientation = (
                "tidak_yakin"
            )

            final_orientation_confidence = (
                raw_orientation_confidence
            )


        # ----------------------------------------------------
        # RESPONSE
        # ----------------------------------------------------

        return jsonify({

            "status":
                "success",


            # ------------------------------------------------
            # CLASSIFICATION
            # ------------------------------------------------

            "classification":
                classification_label,

            "classification_confidence":
                round(
                    classification_confidence * 100,
                    2,
                ),

            "leopard_cat_probability":
                round(
                    leopard_cat_probability * 100,
                    2,
                ),

            "null_probability":
                round(
                    null_probability * 100,
                    2,
                ),


            # ------------------------------------------------
            # THRESHOLD
            # ------------------------------------------------

            "threshold":
                round(
                    LEOPARD_CAT_THRESHOLD * 100,
                    2,
                ),


            # ------------------------------------------------
            # ORIENTATION
            # ------------------------------------------------

            "orientation":
                final_orientation,

            "orientation_confidence":
                round(
                    final_orientation_confidence * 100,
                    2,
                ),

            "orientation_raw":
                raw_orientation,

            "orientation_raw_confidence":
                round(
                    raw_orientation_confidence * 100,
                    2,
                ),

            "orientation_threshold":
                round(
                    ORIENTATION_CONFIDENCE_THRESHOLD * 100,
                    2,
                ),
        })


    except Exception as e:

        return jsonify({

            "status":
                "error",

            "error":
                str(e),

        }), 500


# ============================================================
# RUN
# ============================================================

if __name__ == "__main__":

    print()
    print("=" * 70)
    print("SERVER READY")
    print("=" * 70)

    print(
        "Classification : "
        "MobileNetV3-Small V3"
    )

    print(
        "Orientation    : "
        "ResNet18 Orientation V2"
    )

    print(
        f"Classification threshold : "
        f"{LEOPARD_CAT_THRESHOLD * 100:.0f}%"
    )

    print(
        f"Orientation threshold    : "
        f"{ORIENTATION_CONFIDENCE_THRESHOLD * 100:.0f}%"
    )

    print(
        "Server         : "
        "http://127.0.0.1:5000"
    )

    print("=" * 70)
    print()

    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False,
    )