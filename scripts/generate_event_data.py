from pathlib import Path
import csv


PROJECT_ROOT = Path(__file__).resolve().parent.parent

CSV_PATH = (
    PROJECT_ROOT.parent
    / "02_DATASET"
    / "dataset"
    / "event_dataset.csv"
)

OUTPUT_PATH = PROJECT_ROOT / "lib" / "data" / "event_data.dart"


def dart_string(value: str) -> str:
    """Escape string agar aman digunakan sebagai String Dart."""
    return value.replace("\\", "\\\\").replace("'", "\\'")


def main():
    print("=" * 60)
    print("GENERATE EVENT DATA")
    print("=" * 60)
    print(f"Input  : {CSV_PATH}")
    print(f"Output : {OUTPUT_PATH}")
    print()

    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV tidak ditemukan: {CSV_PATH}")

    rows = []

    with CSV_PATH.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as file:
        reader = csv.DictReader(file)

        for row in reader:
            event_id = row["event_id"]
            label = row["label"]
            timestamp = row["timestamp"]

            photo_paths = [
                f"assets/events/{event_id}_1.JPG",
                f"assets/events/{event_id}_2.JPG",
                f"assets/events/{event_id}_3.JPG",
            ]

            rows.append(
                {
                    "event_id": event_id,
                    "label": label,
                    "timestamp": timestamp,
                    "photo_paths": photo_paths,
                }
            )

    lines = []

    lines.append("import '../models/camera_trap_event.dart';")
    lines.append("")
    lines.append("const List<CameraTrapEvent> eventData = [")
    lines.append("")

    for event in rows:
        lines.append("  CameraTrapEvent(")
        lines.append(
            f"    eventId: '{dart_string(event['event_id'])}',"
        )
        lines.append(
            f"    label: '{dart_string(event['label'])}',"
        )
        lines.append(
            f"    timestamp: '{dart_string(event['timestamp'])}',"
        )
        lines.append("    photoPaths: [")

        for photo_path in event["photo_paths"]:
            lines.append(
                f"      '{dart_string(photo_path)}',"
            )

        lines.append("    ],")
        lines.append("  ),")
        lines.append("")

    lines.append("];")
    lines.append("")

    OUTPUT_PATH.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    OUTPUT_PATH.write_text(
        "\n".join(lines),
        encoding="utf-8",
    )

    print("=" * 60)
    print("SELESAI")
    print("=" * 60)
    print(f"Total event : {len(rows)}")
    print(f"File        : {OUTPUT_PATH}")
    print()


if __name__ == "__main__":
    main()