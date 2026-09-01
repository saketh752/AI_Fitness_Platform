from app.analysis.phase_detection import (
    classify_direction,
    detect_direction_changes,
)


def main():
    print("Testing movement phase detection")
    print("=" * 60)
    print()

    # --------------------------------------------------
    # Direction classification
    # --------------------------------------------------

    assert (
        classify_direction(
            100.0,
            90.0,
        )
        == "decreasing"
    )

    assert (
        classify_direction(
            90.0,
            100.0,
        )
        == "increasing"
    )

    assert (
        classify_direction(
            100.0,
            100.4,
        )
        == "stable"
    )

    print(
        "Direction classification: PASSED"
    )

    # --------------------------------------------------
    # Direction changes
    # --------------------------------------------------

    values = [
        (0, 0, 160.0),
        (1, 100, 150.0),
        (2, 200, 140.0),
        (3, 300, 130.0),
        (4, 400, 135.0),
        (5, 500, 145.0),
        (6, 600, 155.0),
    ]

    changes = detect_direction_changes(
        values,
        tolerance=1.0,
    )

    print()
    print("Detected direction changes")
    print("-" * 60)

    for change in changes:
        print(
            f"Frame {change.frame_index}: "
            f"{change.value:.2f}° "
            f"{change.phase}"
        )

    assert len(changes) == 1

    assert (
        changes[0].phase
        == "decreasing_to_increasing"
    )

    print()
    print(
        "Direction-change detection: PASSED"
    )

    # --------------------------------------------------
    # Stable values should not create noise
    # --------------------------------------------------

    stable_values = [
        (0, 0, 100.0),
        (1, 100, 100.2),
        (2, 200, 99.9),
        (3, 300, 100.1),
        (4, 400, 100.0),
    ]

    stable_changes = detect_direction_changes(
        stable_values,
        tolerance=1.0,
    )

    assert len(stable_changes) == 0

    print(
        "Stable-signal protection: PASSED"
    )

    print()
    print(
        "Phase detection test: PASSED"
    )


if __name__ == "__main__":
    main()