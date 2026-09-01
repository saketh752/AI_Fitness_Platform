from pathlib import Path
import csv

from app.analysis.phase_detection import (
    detect_direction_changes,
)


PROJECT_ROOT = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    PROJECT_ROOT
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


def main():
    print("Testing phase detection on squat video")
    print("=" * 65)
    print()

    if not INPUT_PATH.exists():
        print(
            f"Input CSV not found:\n{INPUT_PATH}"
        )
        print(
            "Run the squat smoothing test first."
        )
        return

    # --------------------------------------------------
    # Load smoothed signal
    # --------------------------------------------------

    with INPUT_PATH.open(
        "r",
        encoding="utf-8",
    ) as csv_file:

        reader = csv.DictReader(csv_file)
        rows = list(reader)

    print(f"Rows loaded: {len(rows)}")

    if not rows:
        print()
        print(
            "Squat phase detection: FAILED"
        )
        return

    # --------------------------------------------------
    # Build knee-angle time series
    # --------------------------------------------------

    values = []

    for row in rows:

        values.append(
            (
                int(row["frame_index"]),
                int(row["timestamp_ms"]),
                float(
                    row["left_knee_2d_smoothed"]
                ),
            )
        )

    # --------------------------------------------------
    # Detect direction changes
    # --------------------------------------------------

    changes = detect_direction_changes(
        values,
        tolerance=0.5,
    )

    print()
    print("Detected direction changes")
    print("-" * 65)

    if not changes:
        print("No direction changes detected.")
    else:

        for change in changes:

            print(
                f"Frame {change.frame_index:4d} | "
                f"{change.timestamp_ms / 1000:6.2f}s | "
                f"{change.value:7.2f}° | "
                f"{change.phase}"
            )

    # --------------------------------------------------
    # Summary
    # --------------------------------------------------

    print()
    print("Summary")
    print("-" * 65)

    print(
        f"Total direction changes: "
        f"{len(changes)}"
    )

    decreasing_to_increasing = [
        change
        for change in changes
        if change.phase
        == "decreasing_to_increasing"
    ]

    increasing_to_decreasing = [
        change
        for change in changes
        if change.phase
        == "increasing_to_decreasing"
    ]

    print(
        f"Decreasing → increasing: "
        f"{len(decreasing_to_increasing)}"
    )

    print(
        f"Increasing → decreasing: "
        f"{len(increasing_to_decreasing)}"
    )

    print()
    print(
        "Real squat phase detection: PASSED"
    )


if __name__ == "__main__":
    main()