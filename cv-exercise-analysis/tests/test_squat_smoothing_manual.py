from pathlib import Path
import csv

from app.analysis.smoothing import MovingAverageSmoother


PROJECT_ROOT = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    PROJECT_ROOT
    / "data"
    / "analysis"
    / "squat_timeseries.csv"
)

OUTPUT_PATH = (
    PROJECT_ROOT
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


def main():
    print("Testing smoothing on squat time series")
    print("=" * 60)
    print()

    if not INPUT_PATH.exists():
        print(
            f"Input CSV not found:\n{INPUT_PATH}"
        )
        print(
            "Run the squat time-series test first."
        )
        return

    # --------------------------------------------------
    # Load raw measurements
    # --------------------------------------------------

    with INPUT_PATH.open(
        "r",
        encoding="utf-8",
    ) as csv_file:

        reader = csv.DictReader(csv_file)
        rows = list(reader)

    print(f"Input rows: {len(rows)}")

    if not rows:
        print("Smoothing test: FAILED")
        return

    # --------------------------------------------------
    # Create smoothers
    # --------------------------------------------------

    left_knee_smoother = MovingAverageSmoother(
        window_size=5
    )

    right_knee_smoother = MovingAverageSmoother(
        window_size=5
    )

    # --------------------------------------------------
    # Apply smoothing
    # --------------------------------------------------

    for row in rows:

        left_knee = float(
            row["left_knee_2d"]
        )

        right_knee = float(
            row["right_knee_2d"]
        )

        row["left_knee_2d_smoothed"] = (
            left_knee_smoother.update(
                left_knee
            )
        )

        row["right_knee_2d_smoothed"] = (
            right_knee_smoother.update(
                right_knee
            )
        )

    # --------------------------------------------------
    # Write output
    # --------------------------------------------------

    fieldnames = list(rows[0].keys())

    with OUTPUT_PATH.open(
        "w",
        newline="",
        encoding="utf-8",
    ) as csv_file:

        writer = csv.DictWriter(
            csv_file,
            fieldnames=fieldnames,
        )

        writer.writeheader()
        writer.writerows(rows)

    # --------------------------------------------------
    # Print selected comparisons
    # --------------------------------------------------

    print()
    print("Raw vs smoothed left knee")
    print("-" * 60)

    sample_indices = [
        0,
        1,
        2,
        3,
        4,
        len(rows) // 4,
        len(rows) // 2,
        (len(rows) * 3) // 4,
        len(rows) - 1,
    ]

    for index in sample_indices:

        row = rows[index]

        print(
            f"Frame {int(row['frame_index']):4d}: "
            f"raw={float(row['left_knee_2d']):7.2f}° "
            f"→ "
            f"smoothed="
            f"{float(row['left_knee_2d_smoothed']):7.2f}°"
        )

    # --------------------------------------------------
    # Validate output
    # --------------------------------------------------

    if len(rows) != 1299:
        print()
        print(
            "Unexpected row count."
        )
        print(
            "Smoothing test: FAILED"
        )
        return

    if not OUTPUT_PATH.exists():
        print()
        print(
            "Output CSV was not created."
        )
        print(
            "Smoothing test: FAILED"
        )
        return

    print()
    print(f"Output CSV: {OUTPUT_PATH}")
    print()
    print(
        "Real-signal smoothing test: PASSED"
    )


if __name__ == "__main__":
    main()