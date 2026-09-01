from app.analysis.squat_phases import (
    SquatPhaseEvent,
)

from app.analysis.rep_detector import (
    SquatRepetitionDetector,
)


def main():

    print("Testing repetition detection")
    print("=" * 65)
    print()

    detector = SquatRepetitionDetector()

    events = [
        SquatPhaseEvent(
            frame_index=10,
            timestamp_ms=1000,
            angle=158.0,
            phase="descending",
        ),

        SquatPhaseEvent(
            frame_index=30,
            timestamp_ms=2000,
            angle=90.0,
            phase="bottom",
        ),

        SquatPhaseEvent(
            frame_index=40,
            timestamp_ms=2500,
            angle=95.0,
            phase="ascending",
        ),

        SquatPhaseEvent(
            frame_index=60,
            timestamp_ms=3500,
            angle=165.0,
            phase="standing",
        ),
    ]

    completed = []

    for event in events:

        repetition = detector.update(event)

        if repetition:
            completed.append(
                repetition
            )

    print("Detected repetitions")
    print("-" * 65)

    for repetition in completed:

        print(
            f"Rep {repetition.repetition_number}: "
            f"frames "
            f"{repetition.start_frame} → "
            f"{repetition.bottom_frame} → "
            f"{repetition.end_frame}"
        )

        print(
            f"  Minimum angle: "
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
            f"  Total: "
            f"{repetition.total_duration_ms} ms"
        )

    assert len(completed) == 1

    repetition = completed[0]

    assert repetition.repetition_number == 1
    assert repetition.start_frame == 10
    assert repetition.bottom_frame == 30
    assert repetition.end_frame == 60

    assert repetition.minimum_angle == 90.0

    assert (
        repetition.descent_duration_ms
        == 1000
    )

    assert (
        repetition.ascent_duration_ms
        == 1500
    )

    assert (
        repetition.total_duration_ms
        == 2500
    )

    print()
    print(
        "Complete repetition detection: PASSED"
    )

    # --------------------------------------------------
    # Incomplete movement must not count
    # --------------------------------------------------

    detector.reset()

    incomplete_events = [
        SquatPhaseEvent(
            frame_index=100,
            timestamp_ms=5000,
            angle=158.0,
            phase="descending",
        ),

        SquatPhaseEvent(
            frame_index=120,
            timestamp_ms=6000,
            angle=90.0,
            phase="bottom",
        ),

        SquatPhaseEvent(
            frame_index=130,
            timestamp_ms=6500,
            angle=95.0,
            phase="ascending",
        ),
    ]

    for event in incomplete_events:
        detector.update(event)

    assert len(
        detector.get_repetitions()
    ) == 0

    print(
        "Incomplete repetition protection: PASSED"
    )

    print()
    print(
        "Repetition detection test: PASSED"
    )


if __name__ == "__main__":
    main()