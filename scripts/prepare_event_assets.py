from pathlib import Path
import csv
import shutil


# ============================================================
# CONFIG
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent.parent

CSV_PATH = (
    PROJECT_ROOT.parent
    / "02_DATASET"
    / "dataset"
    / "event_dataset.csv"
)

OUTPUT_DIR = PROJECT_ROOT / "assets" / "events"


# ============================================================
# PREPARE OUTPUT FOLDER
# ============================================================

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# READ EVENT DATA
# ============================================================

with CSV_PATH.open(
    "r",
    encoding="utf-8-sig",
    newline="",
) as file:

    reader = csv.DictReader(file)

    rows = list(reader)


print("=" * 60)
print("PREPARE EVENT ASSETS")
print("=" * 60)

print(f"CSV       : {CSV_PATH}")
print(f"Output    : {OUTPUT_DIR}")
print(f"Total row : {len(rows)}")
print()


# ============================================================
# COPY PHOTOS
# ============================================================

success_events = 0
failed_events = 0

for row in rows:

    event_id = row["event_id"]

    photos = [
        row["foto_1"],
        row["foto_2"],
        row["foto_3"],
    ]

    event_success = True

    for index, source_string in enumerate(photos, start=1):

        source = Path(source_string)

        if not source.exists():
            print(
                f"[ERROR] {event_id} "
                f"photo {index} tidak ditemukan:"
            )
            print(f"        {source}")

            event_success = False
            continue

        extension = source.suffix.lower()

        destination = (
            OUTPUT_DIR
            / f"{event_id}_{index}{extension}"
        )

        shutil.copy2(
            source,
            destination,
        )

    if event_success:
        success_events += 1
    else:
        failed_events += 1


# ============================================================
# SUMMARY
# ============================================================

print()
print("=" * 60)
print("SELESAI")
print("=" * 60)

print(f"Event berhasil : {success_events}")
print(f"Event gagal    : {failed_events}")

print()
print("Asset directory:")
print(OUTPUT_DIR)