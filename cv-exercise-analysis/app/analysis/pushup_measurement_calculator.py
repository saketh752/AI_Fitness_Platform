from typing import Any

from app.analysis.joint_angles import (
    calculate_joint_angle_2d,
)


def _get_landmark(
    landmarks: list[Any],
    name: str,
) -> Any:
    """Find a landmark by name."""

    for landmark in landmarks:
        if landmark.name == name:
            return landmark

    raise ValueError(
        f"Landmark not found: {name}"
    )


def calculate_elbow_angles(
    landmarks: list[Any],
) -> dict[str, float]:
    """
    Calculate left and right elbow angles.

    The elbow angle is calculated as:

        shoulder -> elbow -> wrist
    """

    left_elbow = calculate_joint_angle_2d(
        landmarks,
        "left_shoulder",
        "left_elbow",
        "left_wrist",
    )

    right_elbow = calculate_joint_angle_2d(
        landmarks,
        "right_shoulder",
        "right_elbow",
        "right_wrist",
    )

    return {
        "left": left_elbow,
        "right": right_elbow,
    }


def calculate_average_elbow_angle(
    landmarks: list[Any],
) -> float:
    """
    Calculate the average elbow angle from
    the left and right elbows.
    """

    angles = calculate_elbow_angles(
        landmarks
    )

    return (
        angles["left"]
        + angles["right"]
    ) / 2.0


def calculate_elbow_symmetry(
    landmarks: list[Any],
) -> float:
    """
    Calculate the absolute difference between
    left and right elbow angles.

    A smaller value means the elbows are more
    symmetrical.
    """

    angles = calculate_elbow_angles(
        landmarks
    )

    return abs(
        angles["left"]
        - angles["right"]
    )


def calculate_body_line_angle(
    landmarks: list[Any],
) -> float:
    """
    Calculate the body-line angle using:

        shoulder -> hip -> knee

    averaged across both sides.

    This is used as a simple measure of
    body alignment during a push-up.
    """

    left_angle = calculate_joint_angle_2d(
        landmarks,
        "left_shoulder",
        "left_hip",
        "left_knee",
    )

    right_angle = calculate_joint_angle_2d(
        landmarks,
        "right_shoulder",
        "right_hip",
        "right_knee",
    )

    return (
        left_angle
        + right_angle
    ) / 2.0


def calculate_pushup_frame_measurements(
    landmarks: list[Any],
) -> dict[str, float]:
    """
    Calculate all push-up measurements available
    from one pose frame.

    This function only performs geometric calculations.
    It does not decide whether the push-up is correct.
    """

    elbow_angles = calculate_elbow_angles(
        landmarks
    )

    average_elbow = (
        elbow_angles["left"]
        + elbow_angles["right"]
    ) / 2.0

    symmetry = abs(
        elbow_angles["left"]
        - elbow_angles["right"]
    )

    body_line = calculate_body_line_angle(
        landmarks
    )

    return {
        "left_elbow_angle": elbow_angles["left"],
        "right_elbow_angle": elbow_angles["right"],
        "average_elbow_angle": average_elbow,
        "elbow_symmetry": symmetry,
        "body_line_angle": body_line,
    }