from app.pose.landmarks import Landmark
from app.analysis.geometry import (
    calculate_angle_2d,
    calculate_angle_3d,
)


def _get_landmark(
    landmarks: list[Landmark],
    name: str,
) -> Landmark:
    """Find a landmark by name."""

    for landmark in landmarks:
        if landmark.name == name:
            return landmark

    raise ValueError(
        f"Landmark not found: {name}"
    )


def calculate_joint_angle_2d(
    landmarks: list[Landmark],
    point_a: str,
    joint: str,
    point_c: str,
) -> float:
    """
    Calculate a joint angle using normalized image coordinates.

    Example:
        hip -> knee -> ankle
        calculates the knee angle.
    """

    a = _get_landmark(landmarks, point_a)
    b = _get_landmark(landmarks, joint)
    c = _get_landmark(landmarks, point_c)

    return calculate_angle_2d(
        (a.x, a.y),
        (b.x, b.y),
        (c.x, c.y),
    )


def calculate_joint_angle_3d(
    landmarks: list[Landmark],
    point_a: str,
    joint: str,
    point_c: str,
) -> float:
    """
    Calculate a joint angle using MediaPipe world coordinates.
    """

    a = _get_landmark(landmarks, point_a)
    b = _get_landmark(landmarks, joint)
    c = _get_landmark(landmarks, point_c)

    return calculate_angle_3d(
        (a.world_x, a.world_y, a.world_z),
        (b.world_x, b.world_y, b.world_z),
        (c.world_x, c.world_y, c.world_z),
    )


def calculate_squat_joint_angles(
    landmarks: list[Landmark],
) -> dict[str, float]:
    """
    Calculate the main joint angles useful for squat analysis.

    This function does NOT determine whether the squat
    is correct or incorrect. It only calculates geometry.
    """

    return {
        "left_knee_2d": calculate_joint_angle_2d(
            landmarks,
            "left_hip",
            "left_knee",
            "left_ankle",
        ),
        "right_knee_2d": calculate_joint_angle_2d(
            landmarks,
            "right_hip",
            "right_knee",
            "right_ankle",
        ),
        "left_hip_2d": calculate_joint_angle_2d(
            landmarks,
            "left_shoulder",
            "left_hip",
            "left_knee",
        ),
        "right_hip_2d": calculate_joint_angle_2d(
            landmarks,
            "right_shoulder",
            "right_hip",
            "right_knee",
        ),
        "left_knee_3d": calculate_joint_angle_3d(
            landmarks,
            "left_hip",
            "left_knee",
            "left_ankle",
        ),
        "right_knee_3d": calculate_joint_angle_3d(
            landmarks,
            "right_hip",
            "right_knee",
            "right_ankle",
        ),
        "left_hip_3d": calculate_joint_angle_3d(
            landmarks,
            "left_shoulder",
            "left_hip",
            "left_knee",
        ),
        "right_hip_3d": calculate_joint_angle_3d(
            landmarks,
            "right_shoulder",
            "right_hip",
            "right_knee",
        ),
    }
def calculate_pushup_joint_angles(
    landmarks: list[Landmark],
) -> dict[str, float]:
    """
    Calculate the main joint angles useful for push-up analysis.

    This function only calculates geometry.
    It does not determine whether the push-up
    is correct or incorrect.
    """

    return {
        # ------------------------------------------
        # Left elbow
        # shoulder -> elbow -> wrist
        # ------------------------------------------

        "left_elbow_2d": calculate_joint_angle_2d(
            landmarks,
            "left_shoulder",
            "left_elbow",
            "left_wrist",
        ),

        # ------------------------------------------
        # Right elbow
        # ------------------------------------------

        "right_elbow_2d": calculate_joint_angle_2d(
            landmarks,
            "right_shoulder",
            "right_elbow",
            "right_wrist",
        ),

        # ------------------------------------------
        # Left shoulder
        # ------------------------------------------

        "left_shoulder_2d": calculate_joint_angle_2d(
            landmarks,
            "left_elbow",
            "left_shoulder",
            "left_hip",
        ),

        # ------------------------------------------
        # Right shoulder
        # ------------------------------------------

        "right_shoulder_2d": calculate_joint_angle_2d(
            landmarks,
            "right_elbow",
            "right_shoulder",
            "right_hip",
        ),

        # ------------------------------------------
        # Left hip
        # ------------------------------------------

        "left_hip_2d": calculate_joint_angle_2d(
            landmarks,
            "left_shoulder",
            "left_hip",
            "left_knee",
        ),

        # ------------------------------------------
        # Right hip
        # ------------------------------------------

        "right_hip_2d": calculate_joint_angle_2d(
            landmarks,
            "right_shoulder",
            "right_hip",
            "right_knee",
        ),

        # ------------------------------------------
        # 3D elbow angles
        # ------------------------------------------

        "left_elbow_3d": calculate_joint_angle_3d(
            landmarks,
            "left_shoulder",
            "left_elbow",
            "left_wrist",
        ),

        "right_elbow_3d": calculate_joint_angle_3d(
            landmarks,
            "right_shoulder",
            "right_elbow",
            "right_wrist",
        ),

        # ------------------------------------------
        # 3D shoulder angles
        # ------------------------------------------

        "left_shoulder_3d": calculate_joint_angle_3d(
            landmarks,
            "left_elbow",
            "left_shoulder",
            "left_hip",
        ),

        "right_shoulder_3d": calculate_joint_angle_3d(
            landmarks,
            "right_elbow",
            "right_shoulder",
            "right_hip",
        ),

        # ------------------------------------------
        # 3D hip angles
        # ------------------------------------------

        "left_hip_3d": calculate_joint_angle_3d(
            landmarks,
            "left_shoulder",
            "left_hip",
            "left_knee",
        ),

        "right_hip_3d": calculate_joint_angle_3d(
            landmarks,
            "right_shoulder",
            "right_hip",
            "right_knee",
        ),
    }