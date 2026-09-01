from typing import Iterable


def calculate_pushup_elbow_angles(
    angle_rows: Iterable[dict],
) -> list[float]:
    """
    Extract the average elbow angle for each frame.

    Expects rows containing:
        left_elbow_2d
        right_elbow_2d

    Returns:
        One averaged elbow angle per row.
    """

    angles = []

    for row in angle_rows:
        left = float(row["left_elbow_2d"])
        right = float(row["right_elbow_2d"])

        average = (left + right) / 2.0

        angles.append(average)

    return angles


def calculate_average_elbow_angle(
    left_angle: float,
    right_angle: float,
) -> float:
    """
    Calculate the average of left and right elbow angles.
    """

    return (
        float(left_angle)
        + float(right_angle)
    ) / 2.0


def calculate_elbow_symmetry(
    left_angle: float,
    right_angle: float,
) -> float:
    """
    Calculate the absolute difference between
    left and right elbow angles.
    """

    return abs(
        float(left_angle)
        - float(right_angle)
    )


def calculate_body_line_angle(
    shoulder_angle: float,
    hip_angle: float,
) -> float:
    """
    Estimate body-line quality from shoulder and hip angles.

    This combines the two supplied angles into a
    simple average used by the push-up analysis.
    """

    return (
        float(shoulder_angle)
        + float(hip_angle)
    ) / 2.0