from app.analysis.geometry import (
    calculate_angle_2d,
    calculate_angle_3d,
    calculate_distance_2d,
    calculate_distance_3d,
    calculate_midpoint_2d,
    calculate_midpoint_3d,
)


def main():
    print("Testing movement geometry")
    print("=" * 50)
    print()

    # --------------------------------------------------
    # 2D angle
    # --------------------------------------------------

    angle_2d = calculate_angle_2d(
        (0.0, 0.0),
        (0.0, 1.0),
        (1.0, 1.0),
    )

    print(f"2D angle:       {angle_2d:.2f} degrees")

    assert abs(angle_2d - 90.0) < 0.001

    # --------------------------------------------------
    # 3D angle
    # --------------------------------------------------

    angle_3d = calculate_angle_3d(
        (0.0, 0.0, 0.0),
        (0.0, 1.0, 0.0),
        (1.0, 1.0, 0.0),
    )

    print(f"3D angle:       {angle_3d:.2f} degrees")

    assert abs(angle_3d - 90.0) < 0.001

    # --------------------------------------------------
    # 2D distance
    # --------------------------------------------------

    distance_2d = calculate_distance_2d(
        (0.0, 0.0),
        (3.0, 4.0),
    )

    print(f"2D distance:    {distance_2d:.2f}")

    assert abs(distance_2d - 5.0) < 0.001

    # --------------------------------------------------
    # 3D distance
    # --------------------------------------------------

    distance_3d = calculate_distance_3d(
        (0.0, 0.0, 0.0),
        (2.0, 3.0, 6.0),
    )

    print(f"3D distance:    {distance_3d:.2f}")

    assert abs(distance_3d - 7.0) < 0.001

    # --------------------------------------------------
    # 2D midpoint
    # --------------------------------------------------

    midpoint_2d = calculate_midpoint_2d(
        (2.0, 4.0),
        (6.0, 8.0),
    )

    print(f"2D midpoint:    {midpoint_2d}")

    assert midpoint_2d == (4.0, 6.0)

    # --------------------------------------------------
    # 3D midpoint
    # --------------------------------------------------

    midpoint_3d = calculate_midpoint_3d(
        (2.0, 4.0, 6.0),
        (6.0, 8.0, 10.0),
    )

    print(f"3D midpoint:    {midpoint_3d}")

    assert midpoint_3d == (4.0, 6.0, 8.0)

    # --------------------------------------------------
    # Zero-length angle protection
    # --------------------------------------------------

    try:
        calculate_angle_2d(
            (1.0, 1.0),
            (1.0, 1.0),
            (2.0, 2.0),
        )
    except ValueError:
        print("Zero-length protection: PASSED")
    else:
        raise AssertionError(
            "Expected ValueError for overlapping points."
        )

    print()
    print("Geometry test: PASSED")


if __name__ == "__main__":
    main()