import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision


class PoseDetector:
    """Detect human pose landmarks using MediaPipe Pose Landmarker."""

    def __init__(
        self,
        model_path: str,
        min_pose_detection_confidence: float = 0.5,
        min_pose_presence_confidence: float = 0.5,
        min_tracking_confidence: float = 0.5,
    ):
        base_options = python.BaseOptions(
            model_asset_path=model_path
        )

        options = vision.PoseLandmarkerOptions(
            base_options=base_options,
            running_mode=vision.RunningMode.VIDEO,
            num_poses=1,
            min_pose_detection_confidence=(
                min_pose_detection_confidence
            ),
            min_pose_presence_confidence=(
                min_pose_presence_confidence
            ),
            min_tracking_confidence=(
                min_tracking_confidence
            ),
        )

        self.landmarker = vision.PoseLandmarker.create_from_options(
            options
        )

    def detect(self, frame, timestamp_ms: int):
        """
        Detect pose landmarks in an OpenCV BGR frame.

        Args:
            frame: OpenCV BGR image.
            timestamp_ms: Timestamp of the frame in milliseconds.

        Returns:
            MediaPipe PoseLandmarkerResult.
        """

        rgb_frame = mp.Image(
            image_format=mp.ImageFormat.SRGB,
            data=frame[:, :, ::-1],
        )

        return self.landmarker.detect_for_video(
            rgb_frame,
            timestamp_ms,
        )

    def close(self):
        """Release MediaPipe resources."""

        self.landmarker.close()

    def __enter__(self):
        return self

    def __exit__(
        self,
        exc_type,
        exc_value,
        traceback,
    ):
        self.close()