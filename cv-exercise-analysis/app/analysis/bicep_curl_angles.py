from app.analysis.joint_angles import (
    calculate_joint_angle_2d,
)
from app.pose.landmarks import Landmark


def calculate_bicep_curl_elbow_angles(
    landmarks: list[Landmark],
) -> dict[str, float]:
    """
    Calculate left and right elbow angles.

    Elbow angle:
        shoulder -> elbow -> wrist
    """

    return {
        "left": calculate_joint_angle_2d(
            landmarks,
            "left_shoulder",
            "left_elbow",
            "left_wrist",
        ),
        "right": calculate_joint_angle_2d(
            landmarks,
            "right_shoulder",
            "right_elbow",
            "right_wrist",
        ),
    }


def calculate_average_bicep_curl_angle(
    landmarks: list[Landmark],
) -> float:
    """Return the average elbow angle."""

    angles = calculate_bicep_curl_elbow_angles(
        landmarks
    )

    return (
        angles["left"] + angles["right"]
    ) / 2.0


def calculate_bicep_curl_elbow_symmetry(
    landmarks: list[Landmark],
) -> float:
    """Return the absolute difference between elbow angles."""

    angles = calculate_bicep_curl_elbow_angles(
        landmarks
    )

    return abs(
        angles["left"] - angles["right"]
    )


def calculate_bicep_curl_frame_measurements(
    landmarks: list[Landmark],
) -> dict[str, float]:
    """Calculate all frame-level curl measurements."""

    angles = calculate_bicep_curl_elbow_angles(
        landmarks
    )

    average = (
        angles["left"] + angles["right"]
    ) / 2.0

    symmetry = abs(
        angles["left"] - angles["right"]
    )

    return {
        "left_elbow_angle": angles["left"],
        "right_elbow_angle": angles["right"],
        "average_elbow_angle": average,
        "elbow_symmetry": symmetry,
    }