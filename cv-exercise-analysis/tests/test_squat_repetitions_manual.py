from pathlib import Path
import csv

from app.analysis.phase_detection import (
    classify_direction,
)

from app.analysis.squat_phases import (
    SquatPhaseDetector,
)

from app.analysis.rep_detector import (
    SquatRepetitionDetector,
)


PROJECT_ROOT = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    PROJECT_ROOT
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


def main():

    print("Testing squat repetition detection")
    print("=" * 70)
    print()

    if not INPUT_PATH.exists():
        print(
            f"Input CSV not found:\n{INPUT_PATH}"
        )
        return

    # --------------------------------------------------
    # Load data
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

    # --------------------------------------------------
    # Create detectors
    # --------------------------------------------------

    phase_detector = SquatPhaseDetector(
        standing_threshold=160.0,
        depth_threshold=100.0,
    )

    rep_detector = SquatRepetitionDetector()

    # --------------------------------------------------
    # Process signal
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

        phase_event = phase_detector.update(
            angle=angle,
            frame_index=frame_index,
            timestamp_ms=timestamp_ms,
            direction=direction,
        )

        if phase_event:

            repetition = rep_detector.update(
                phase_event
            )

            if repetition:

                print(
                    f"Rep {repetition.repetition_number}: "
                    f"{repetition.start_timestamp_ms / 1000:.2f}s"
                    f" → "
                    f"{repetition.end_timestamp_ms / 1000:.2f}s"
                )

                print(
                    f"  Start frame: "
                    f"{repetition.start_frame}"
                )

                print(
                    f"  Bottom frame: "
                    f"{repetition.bottom_frame}"
                )

                print(
                    f"  End frame: "
                    f"{repetition.end_frame}"
                )

                print(
                    f"  Minimum knee angle: "
                    f"{repetition.minimum_angle:.2f}°"
                )

                print(
                    f"  Descent: "
                    f"{repetition.descent_duration_ms} ms"
                )

                print(
                    f"  Ascent: "
                    f"{repetition.ascent_duration_ms} ms"
                )

                print(
                    f"  Total duration: "
                    f"{repetition.total_duration_ms} ms"
                )

                print()

    # --------------------------------------------------
    # Results
    # --------------------------------------------------

    repetitions = (
        rep_detector.get_repetitions()
    )

    print("Summary")
    print("-" * 70)

    print(
        f"Detected repetitions: "
        f"{len(repetitions)}"
    )

    # --------------------------------------------------
    # Validation
    # --------------------------------------------------

    assert len(repetitions) == 7

    for index, repetition in enumerate(
        repetitions,
        start=1,
    ):

        assert (
            repetition.repetition_number
            == index
        )

        assert (
            repetition.start_frame
            < repetition.bottom_frame
            < repetition.end_frame
        )

        assert (
            repetition.minimum_angle
            <= 100.0
        )

        assert (
            repetition.total_duration_ms
            > 0
        )

    print(
        "7-repetition validation: PASSED"
    )

    print(
        "Frame ordering validation: PASSED"
    )

    print(
        "Depth validation: PASSED"
    )

    print()
    print(
        "Real squat repetition test: PASSED"
    )


if __name__ == "__main__":
    main()