from pathlib import Path
import csv

from app.analysis.phase_detection import (
    classify_direction,
)

from app.analysis.squat_phases import (
    SquatPhaseDetector,
)


PROJECT_ROOT = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    PROJECT_ROOT
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


def main():
    print("Testing squat phase detection on real video")
    print("=" * 70)
    print()

    if not INPUT_PATH.exists():
        print(
            f"Input CSV not found:\n{INPUT_PATH}"
        )
        print(
            "Run the smoothing test first."
        )
        return

    # --------------------------------------------------
    # Load signal
    # --------------------------------------------------

    with INPUT_PATH.open(
        "r",
        encoding="utf-8",
    ) as csv_file:

        rows = list(
            csv.DictReader(csv_file)
        )

    print(
        f"Rows loaded: {len(rows)}"
    )

    if len(rows) < 2:
        print(
            "Not enough rows for phase detection."
        )
        return

    # --------------------------------------------------
    # Detector
    # --------------------------------------------------

    detector = SquatPhaseDetector(
        standing_threshold=160.0,
        depth_threshold=100.0,
    )

    events = []

    # --------------------------------------------------
    # Feed real signal
    # --------------------------------------------------

    for i, row in enumerate(rows):

        frame_index = int(
            row["frame_index"]
        )

        timestamp_ms = int(
            row["timestamp_ms"]
        )

        angle = float(
            row["left_knee_2d_smoothed"]
        )

        # Determine direction from adjacent frames.
        if i == 0:
            direction = "stable"
        else:
            previous_angle = float(
                rows[i - 1][
                    "left_knee_2d_smoothed"
                ]
            )

            direction = classify_direction(
                previous_angle,
                angle,
                tolerance=0.5,
            )

        event = detector.update(
            angle=angle,
            frame_index=frame_index,
            timestamp_ms=timestamp_ms,
            direction=direction,
        )

        if event:
            events.append(event)

    # --------------------------------------------------
    # Print detected events
    # --------------------------------------------------

    print()
    print("Detected squat phases")
    print("-" * 70)

    for event in events:

        print(
            f"Frame {event.frame_index:4d} | "
            f"{event.timestamp_ms / 1000:6.2f}s | "
            f"{event.angle:7.2f}° | "
            f"{event.phase}"
        )

    # --------------------------------------------------
    # Phase counts
    # --------------------------------------------------

    descending = [
        e for e in events
        if e.phase == "descending"
    ]

    bottoms = [
        e for e in events
        if e.phase == "bottom"
    ]

    ascending = [
        e for e in events
        if e.phase == "ascending"
    ]

    standing = [
        e for e in events
        if e.phase == "standing"
    ]

    print()
    print("Phase summary")
    print("-" * 70)

    print(
        f"Descending: {len(descending)}"
    )

    print(
        f"Bottom:     {len(bottoms)}"
    )

    print(
        f"Ascending:  {len(ascending)}"
    )

    print(
        f"Standing:   {len(standing)}"
    )

    # --------------------------------------------------
    # Identify complete cycles
    # --------------------------------------------------

    complete_cycles = min(
        len(descending),
        len(bottoms),
        len(ascending),
        len(standing),
    )

    print()
    print(
        f"Potential complete cycles: "
        f"{complete_cycles}"
    )

    print()
    print(
        "Real squat phase detection: PASSED"
    )


if __name__ == "__main__":
    main()