from app.analysis.squat_phases import (
    SquatPhaseDetector,
)


def main():
    print("Testing squat phase state machine")
    print("=" * 65)
    print()

    detector = SquatPhaseDetector(
        standing_threshold=160.0,
        depth_threshold=100.0,
    )

    sequence = [
        # frame, timestamp, angle, direction
        (0, 0, 175.0, "stable"),
        (1, 100, 150.0, "decreasing"),
        (2, 200, 120.0, "decreasing"),
        (3, 300, 90.0, "decreasing"),
        (4, 400, 85.0, "stable"),
        (5, 500, 95.0, "increasing"),
        (6, 600, 120.0, "increasing"),
        (7, 700, 165.0, "increasing"),
        (8, 800, 175.0, "stable"),
    ]

    events = []

    for frame, timestamp, angle, direction in sequence:

        event = detector.update(
            angle=angle,
            frame_index=frame,
            timestamp_ms=timestamp,
            direction=direction,
        )

        if event:
            events.append(event)

    print("Detected phases")
    print("-" * 65)

    for event in events:

        print(
            f"Frame {event.frame_index}: "
            f"{event.angle:.1f}° → "
            f"{event.phase}"
        )

    expected = [
        "descending",
        "bottom",
        "ascending",
        "standing",
    ]

    actual = [
        event.phase
        for event in events
    ]

    assert actual == expected

    print()
    print(
        "Phase ordering: PASSED"
    )

    # --------------------------------------------------
    # Shallow movement should not reach bottom
    # --------------------------------------------------

    detector.reset()

    shallow_sequence = [
        (0, 0, 175.0, "stable"),
        (1, 100, 150.0, "decreasing"),
        (2, 200, 125.0, "decreasing"),
        (3, 300, 110.0, "decreasing"),
        (4, 400, 150.0, "increasing"),
        (5, 500, 175.0, "increasing"),
    ]

    shallow_events = []

    for frame, timestamp, angle, direction in shallow_sequence:

        event = detector.update(
            angle=angle,
            frame_index=frame,
            timestamp_ms=timestamp,
            direction=direction,
        )

        if event:
            shallow_events.append(event)

    assert all(
        event.phase != "bottom"
        for event in shallow_events
    )

    print(
        "Shallow squat protection: PASSED"
    )

    print()
    print(
        "Squat phase state-machine test: PASSED"
    )


if __name__ == "__main__":
    main()