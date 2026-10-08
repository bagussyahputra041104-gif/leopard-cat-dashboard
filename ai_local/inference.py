import sys
from pathlib import Path

import torch
import torch.nn as nn
from PIL import Image
from torchvision import models, transforms


# ============================================================
# PATH
# ============================================================

# Folder ai_local/
BASE_DIR = Path(__file__).resolve().parent

# Folder ai_local/models/
MODEL_DIR = BASE_DIR / "models"

# Final classification model
CLASSIFICATION_MODEL = (
    MODEL_DIR
    / "mobilenetv3_small_v3_best.pth"
)

# Final orientation model
ORIENTATION_MODEL = (
    MODEL_DIR
    / "resnet18_orientation_v2_best.pth"
)


# ============================================================
# CONFIGURATION
# ============================================================

IMAGE_SIZE = 224

# Leopard Cat probability >= 50%
LEOPARD_CAT_THRESHOLD = 0.50

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)


# ============================================================
# CLASS NAMES
# ============================================================

CLASSIFICATION_CLASSES = {
    0: "leopard_cat",
    1: "null",
}

ORIENTATION_CLASSES = [
    "depan",
    "belakang",
    "kiri",
    "kanan",
    "tidak_yakin",
    "null",
]


# ============================================================
# IMAGE TRANSFORM
# ============================================================

transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


# ============================================================
# LOAD CLASSIFICATION MODEL
# ============================================================

def load_classification_model():

    print("Path model classification:")
    print(CLASSIFICATION_MODEL)

    if not CLASSIFICATION_MODEL.exists():

        raise FileNotFoundError(
            "Model classification tidak ditemukan:\n"
            f"{CLASSIFICATION_MODEL}"
        )

    checkpoint = torch.load(
        CLASSIFICATION_MODEL,
        map_location=DEVICE,
    )

    model = models.mobilenet_v3_small(
        weights=None
    )

    model.classifier[3] = nn.Linear(
        model.classifier[3].in_features,
        2,
    )

    if isinstance(checkpoint, dict):

        if "model_state_dict" in checkpoint:

            state_dict = (
                checkpoint["model_state_dict"]
            )

        elif "state_dict" in checkpoint:

            state_dict = (
                checkpoint["state_dict"]
            )

        else:

            state_dict = checkpoint

    else:

        raise RuntimeError(
            "Format checkpoint MobileNetV3 "
            "tidak dikenali."
        )

    model.load_state_dict(
        state_dict
    )

    model.to(DEVICE)

    model.eval()

    print(
        "MobileNetV3-Small berhasil dimuat."
    )

    return (
        model,
        CLASSIFICATION_CLASSES,
    )


# ============================================================
# LOAD ORIENTATION MODEL
# ============================================================

def load_orientation_model():

    print("Path model orientation:")
    print(ORIENTATION_MODEL)

    if not ORIENTATION_MODEL.exists():

        raise FileNotFoundError(
            "Model orientation tidak ditemukan:\n"
            f"{ORIENTATION_MODEL}"
        )

    checkpoint = torch.load(
        ORIENTATION_MODEL,
        map_location=DEVICE,
    )

    if (
        isinstance(checkpoint, dict)
        and "class_names" in checkpoint
    ):

        class_names = checkpoint[
            "class_names"
        ]

    else:

        class_names = ORIENTATION_CLASSES

    model = models.resnet18(
        weights=None
    )

    model.fc = nn.Linear(
        model.fc.in_features,
        len(class_names),
    )

    if (
        isinstance(checkpoint, dict)
        and "model_state_dict" in checkpoint
    ):

        state_dict = (
            checkpoint["model_state_dict"]
        )

    elif (
        isinstance(checkpoint, dict)
        and "state_dict" in checkpoint
    ):

        state_dict = (
            checkpoint["state_dict"]
        )

    else:

        state_dict = checkpoint

    model.load_state_dict(
        state_dict
    )

    model.to(DEVICE)

    model.eval()

    print(
        "ResNet18 Orientation berhasil dimuat."
    )

    return (
        model,
        class_names,
    )


# ============================================================
# PREPARE IMAGE
# ============================================================

def prepare_image(image):

    tensor = transform(
        image
    )

    tensor = tensor.unsqueeze(
        0
    )

    return tensor.to(
        DEVICE
    )


# ============================================================
# CLASSIFICATION
# ============================================================

def predict_classification(
    model,
    class_names,
    image,
):

    tensor = prepare_image(
        image
    )

    with torch.no_grad():

        outputs = model(
            tensor
        )

        probabilities = torch.softmax(
            outputs,
            dim=1,
        )

    leopard_cat_probability = (
        probabilities[
            0,
            0
        ].item()
    )

    null_probability = (
        probabilities[
            0,
            1
        ].item()
    )

    if (
        leopard_cat_probability
        >= LEOPARD_CAT_THRESHOLD
    ):

        label = "leopard_cat"

        confidence = (
            leopard_cat_probability
        )

    else:

        label = "null"

        confidence = (
            null_probability
        )

    return {
        "label": label,
        "confidence": confidence,
        "leopard_cat_probability":
            leopard_cat_probability,
        "null_probability":
            null_probability,
    }


# ============================================================
# ORIENTATION
# ============================================================

def predict_orientation(
    model,
    class_names,
    image,
):

    tensor = prepare_image(
        image
    )

    with torch.no_grad():

        outputs = model(
            tensor
        )

        probabilities = torch.softmax(
            outputs,
            dim=1,
        )

        confidence, predicted = (
            torch.max(
                probabilities,
                dim=1,
            )
        )

    predicted_index = (
        predicted.item()
    )

    label = class_names[
        predicted_index
    ]

    confidence_value = (
        confidence.item()
    )

    return {
        "label": label,
        "confidence": confidence_value,
    }


# ============================================================
# COMPLETE INFERENCE
# ============================================================

def run_models(
    classification_model,
    classification_classes,
    orientation_model,
    orientation_classes,
    image,
):

    classification = (
        predict_classification(
            classification_model,
            classification_classes,
            image,
        )
    )

    # ========================================================
    # PENTING:
    # Orientation TIDAK bergantung pada classification.
    #
    # Jadi walaupun classification = NULL,
    # orientation tetap dijalankan.
    # ========================================================

    orientation = (
        predict_orientation(
            orientation_model,
            orientation_classes,
            image,
        )
    )

    return {
        "classification":
            classification,

        "orientation":
            orientation,
    }


# ============================================================
# COMMAND LINE TEST
# ============================================================

def run_inference(
    image_path
):

    image_path = Path(
        image_path
    )

    if not image_path.exists():

        raise FileNotFoundError(
            f"Foto tidak ditemukan: "
            f"{image_path}"
        )

    image = Image.open(
        image_path
    ).convert(
        "RGB"
    )

    print()
    print(
        "=" * 70
    )

    print(
        "LEOPARD CAT AI TEST"
    )

    print(
        "=" * 70
    )

    print()

    print(
        "Foto:"
    )

    print(
        image_path
    )

    print()

    print(
        "Device:"
    )

    print(
        DEVICE
    )

    # ========================================================
    # LOAD CLASSIFICATION
    # ========================================================

    print()

    print(
        "Memuat model classification..."
    )

    (
        classification_model,
        classification_classes,
    ) = load_classification_model()

    # ========================================================
    # LOAD ORIENTATION
    # ========================================================

    print()

    print(
        "Memuat model orientation..."
    )

    (
        orientation_model,
        orientation_classes,
    ) = load_orientation_model()

    # ========================================================
    # RUN BOTH
    # ========================================================

    result = run_models(
        classification_model,
        classification_classes,
        orientation_model,
        orientation_classes,
        image,
    )

    classification = (
        result[
            "classification"
        ]
    )

    orientation = (
        result[
            "orientation"
        ]
    )

    # ========================================================
    # CLASSIFICATION RESULT
    # ========================================================

    print()

    print(
        "-" * 70
    )

    print(
        "CLASSIFICATION"
    )

    print(
        "-" * 70
    )

    print()

    print(
        f"Hasil              : "
        f"{classification['label']}"
    )

    print(
        f"Confidence         : "
        f"{classification['confidence'] * 100:.2f}%"
    )

    print(
        f"Prob. Leopard Cat  : "
        f"{classification['leopard_cat_probability'] * 100:.2f}%"
    )

    print(
        f"Prob. NULL         : "
        f"{classification['null_probability'] * 100:.2f}%"
    )

    print(
        f"Threshold          : "
        f"{LEOPARD_CAT_THRESHOLD * 100:.0f}%"
    )

    # ========================================================
    # ORIENTATION RESULT
    # ========================================================

    print()

    print(
        "-" * 70
    )

    print(
        "ORIENTATION"
    )

    print(
        "-" * 70
    )

    print()

    print(
        f"Arah               : "
        f"{orientation['label']}"
    )

    print(
        f"Confidence         : "
        f"{orientation['confidence'] * 100:.2f}%"
    )

    # ========================================================
    # FINISH
    # ========================================================

    print()

    print(
        "=" * 70
    )

    print(
        "SELESAI"
    )

    print(
        "=" * 70
    )


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    if len(sys.argv) < 2:

        print()

        print(
            "Cara penggunaan:"
        )

        print()

        print(
            'py .\\ai_local\\inference.py '
            '"path\\ke\\foto.jpg"'
        )

        print()

        sys.exit(
            1
        )

    image_path = (
        sys.argv[1]
    )

    run_inference(
        image_path
    )