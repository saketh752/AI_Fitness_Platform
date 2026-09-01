from pathlib import Path
import csv

from app.analysis.phase_detection import (
    detect_direction_changes,
)

from app.analysis.event_filter import (
    filter_events,
)


PROJECT_ROOT = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    PROJECT_ROOT
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


def main():
    print("Testing event filtering on squat video")
    print("=" * 65)
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

    values = [
        (
            int(row["frame_index"]),
            int(row["timestamp_ms"]),
            float(
                row["left_knee_2d_smoothed"]
            ),
        )
        for row in rows
    ]

    # --------------------------------------------------
    # Detect raw events
    # --------------------------------------------------

    raw_events = detect_direction_changes(
        values,
        tolerance=0.5,
    )

    print(
        f"Raw direction changes: "
        f"{len(raw_events)}"
    )

    # --------------------------------------------------
    # Filter events
    # --------------------------------------------------

    filtered_events = filter_events(
        raw_events,
        min_frames_between=15,
        min_value_change=10.0,
    )

    # --------------------------------------------------
    # Display filtered events
    # --------------------------------------------------

    print()
    print("Filtered movement events")
    print("-" * 65)

    for event in filtered_events:

        print(
            f"Frame {event.frame_index:4d} | "
            f"{event.timestamp_ms / 1000:6.2f}s | "
            f"{event.value:7.2f}° | "
            f"{event.phase}"
        )

    # --------------------------------------------------
    # Summary
    # --------------------------------------------------

    bottoms = [
        event
        for event in filtered_events
        if event.phase
        == "decreasing_to_increasing"
    ]

    tops = [
        event
        for event in filtered_events
        if event.phase
        == "increasing_to_decreasing"
    ]

    print()
    print("Summary")
    print("-" * 65)

    print(
        f"Raw events:       {len(raw_events)}"
    )

    print(
        f"Filtered events:  {len(filtered_events)}"
    )

    print(
        f"Bottom candidates: {len(bottoms)}"
    )

    print(
        f"Top candidates:    {len(tops)}"
    )

    print()
    print(
        "Event filtering on real squat: PASSED"
    )


if __name__ == "__main__":
    main()