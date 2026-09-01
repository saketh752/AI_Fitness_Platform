from dataclasses import asdict, dataclass
from typing import Any


@dataclass
class Landmark:
    """Single pose landmark."""

    index: int
    name: str

    # Normalized image coordinates
    x: float
    y: float
    z: float

    # MediaPipe visibility/presence information
    visibility: float
    presence: float

    # World coordinates in meters
    world_x: float
    world_y: float
    world_z: float

    def to_dict(self) -> dict[str, Any]:
        """Convert landmark to a JSON-compatible dictionary."""
        return asdict(self)


# MediaPipe Pose Landmarker landmark ordering.
POSE_LANDMARK_NAMES = [
    "nose",
    "left_eye_inner",
    "left_eye",
    "left_eye_outer",
    "right_eye_inner",
    "right_eye",
    "right_eye_outer",
    "left_ear",
    "right_ear",
    "mouth_left",
    "mouth_right",
    "left_shoulder",
    "right_shoulder",
    "left_elbow",
    "right_elbow",
    "left_wrist",
    "right_wrist",
    "left_pinky",
    "right_pinky",
    "left_index",
    "right_index",
    "left_thumb",
    "right_thumb",
    "left_hip",
    "right_hip",
    "left_knee",
    "right_knee",
    "left_ankle",
    "right_ankle",
    "left_heel",
    "right_heel",
    "left_foot_index",
    "right_foot_index",
]


def extract_landmarks(results) -> list[Landmark]:
    """
    Convert a MediaPipe PoseLandmarkerResult into
    our internal Landmark representation.

    Returns an empty list when no pose is detected.
    """

    if not results.pose_landmarks:
        return []

    image_landmarks = results.pose_landmarks[0]
    world_landmarks = (
        results.pose_world_landmarks[0]
        if results.pose_world_landmarks
        else None
    )

    landmarks = []

    for index, image_landmark in enumerate(image_landmarks):
        name = (
            POSE_LANDMARK_NAMES[index]
            if index < len(POSE_LANDMARK_NAMES)
            else f"landmark_{index}"
        )

        if world_landmarks:
            world_landmark = world_landmarks[index]

            world_x = world_landmark.x
            world_y = world_landmark.y
            world_z = world_landmark.z
        else:
            world_x = 0.0
            world_y = 0.0
            world_z = 0.0

        landmarks.append(
            Landmark(
                index=index,
                name=name,
                x=image_landmark.x,
                y=image_landmark.y,
                z=image_landmark.z,
                visibility=getattr(
                    image_landmark,
                    "visibility",
                    0.0,
                ),
                presence=getattr(
                    image_landmark,
                    "presence",
                    0.0,
                ),
                world_x=world_x,
                world_y=world_y,
                world_z=world_z,
            )
        )

    return landmarks