from app.analysis.temporal import (
    FrameMeasurement,
    calculate_movement_direction,
)


def main():
    print("Testing temporal movement analysis")
    print("=" * 55)
    print()

    # --------------------------------------------------
    # Frame measurement
    # --------------------------------------------------

    measurement = FrameMeasurement(
        frame_index=100,
        timestamp_ms=1666,
        values={
            "left_knee_angle": 92.5,
            "right_knee_angle": 95.2,
        },
    )

    print("Frame measurement")
    print("-" * 55)

    print(f"Frame:      {measurement.frame_index}")
    print(f"Timestamp:  {measurement.timestamp_ms} ms")
    print(
        f"Left knee:  "
        f"{measurement.get('left_knee_angle')}°"
    )
    print(
        f"Right knee: "
        f"{measurement.get('right_knee_angle')}°"
    )

    assert measurement.get(
        "left_knee_angle"
    ) == 92.5

    assert measurement.get(
        "missing_value"
    ) is None

    # --------------------------------------------------
    # Direction
    # --------------------------------------------------

    decreasing = calculate_movement_direction(
        previous_value=120.0,
        current_value=100.0,
    )

    increasing = calculate_movement_direction(
        previous_value=100.0,
        current_value=120.0,
    )

    stable = calculate_movement_direction(
        previous_value=100.0,
        current_value=100.2,
    )

    print()
    print("Movement directions")
    print("-" * 55)

    print(f"120 → 100: {decreasing}")
    print(f"100 → 120: {increasing}")
    print(f"100 → 100.2: {stable}")

    assert decreasing == "decreasing"
    assert increasing == "increasing"
    assert stable == "stable"

    # --------------------------------------------------
    # Tolerance
    # --------------------------------------------------

    within_tolerance = calculate_movement_direction(
        previous_value=100.0,
        current_value=100.4,
        tolerance=0.5,
    )

    outside_tolerance = calculate_movement_direction(
        previous_value=100.0,
        current_value=100.6,
        tolerance=0.5,
    )

    print()
    print("Tolerance validation")
    print("-" * 55)

    print(f"100 → 100.4: {within_tolerance}")
    print(f"100 → 100.6: {outside_tolerance}")

    assert within_tolerance == "stable"
    assert outside_tolerance == "increasing"

    # --------------------------------------------------
    # Serialization
    # --------------------------------------------------

    dictionary = measurement.to_dict()

    assert dictionary["frame_index"] == 100
    assert dictionary["timestamp_ms"] == 1666
    assert dictionary["values"]["left_knee_angle"] == 92.5

    print()
    print("Dictionary conversion: PASSED")
    print("Temporal analysis test: PASSED")


if __name__ == "__main__":
    main()