import cv2
from dataclasses import dataclass
from pathlib import Path


@dataclass
class VideoMetadata:
    path: str
    width: int
    height: int
    fps: float
    frame_count: int
    duration_seconds: float


class VideoProcessor:
    """Handles basic video validation and frame access."""

    def __init__(self, video_path: str | Path):
        self.video_path = Path(video_path)

        if not self.video_path.exists():
            raise FileNotFoundError(
                f"Video not found: {self.video_path}"
            )

        self.cap = cv2.VideoCapture(
            str(self.video_path)
        )

        if not self.cap.isOpened():
            raise ValueError(
                f"Unable to open video: {self.video_path}"
            )

    def get_metadata(self) -> VideoMetadata:
        """Return basic video metadata."""

        width = int(
            self.cap.get(cv2.CAP_PROP_FRAME_WIDTH)
        )

        height = int(
            self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
        )

        fps = float(
            self.cap.get(cv2.CAP_PROP_FPS)
        )

        frame_count = int(
            self.cap.get(cv2.CAP_PROP_FRAME_COUNT)
        )

        duration_seconds = (
            frame_count / fps
            if fps > 0
            else 0.0
        )

        return VideoMetadata(
            path=str(self.video_path),
            width=width,
            height=height,
            fps=fps,
            frame_count=frame_count,
            duration_seconds=duration_seconds,
        )

    def read_frame(self):
        """Read the next frame from the video."""

        success, frame = self.cap.read()

        if not success:
            return None

        return frame

    def frames(self):
        """
        Yield video frames with frame index
        and timestamp in milliseconds.

        Yields:
            tuple:
                (
                    frame_index,
                    timestamp_ms,
                    frame,
                )
        """

        fps = float(
            self.cap.get(cv2.CAP_PROP_FPS)
        )

        frame_index = 0

        while True:

            frame = self.read_frame()

            if frame is None:
                break

            if fps > 0:
                timestamp_ms = int(
                    (frame_index / fps) * 1000
                )
            else:
                timestamp_ms = 0

            yield (
                frame_index,
                timestamp_ms,
                frame,
            )

            frame_index += 1

    def reset(self):
        """Return to the first frame."""

        self.cap.set(
            cv2.CAP_PROP_POS_FRAMES,
            0,
        )

    def release(self):
        """Release the OpenCV video resource."""

        self.cap.release()

    def __enter__(self):
        return self

    def __exit__(
        self,
        exc_type,
        exc_value,
        traceback,
    ):
        self.release()