from pathlib import Path

from app.preprocessing.video_processor import VideoProcessor
from app.pose.detector import PoseDetector


PROJECT_ROOT = Path(__file__).resolve().parent.parent

VIDEO_PATH = (
    PROJECT_ROOT
    / "videos"
    / "squat"
    / "SquatExerciseVideo.mp4"
)

MODEL_PATH = (
    PROJECT_ROOT
    / "models"
    / "pose_landmarker_full.task"
)


def main():
    print(f"Video: {VIDEO_PATH}")
    print(f"Model: {MODEL_PATH}")
    print()

    with VideoProcessor(VIDEO_PATH) as video:
        metadata = video.get_metadata()

        print("Video metadata")
        print("----------------------------")
        print(f"Width:       {metadata.width}")
        print(f"Height:      {metadata.height}")
        print(f"FPS:         {metadata.fps:.2f}")
        print(f"Frames:      {metadata.frame_count}")
        print(
            f"Duration:    "
            f"{metadata.duration_seconds:.2f} seconds"
        )
        print()

        with PoseDetector(str(MODEL_PATH)) as detector:

            frame_number = 0
            detected_frames = 0

            while True:
                frame = video.read_frame()

                if frame is None:
                    break

                frame_number += 1

                timestamp_ms = int(
                    (frame_number - 1)
                    * 1000
                    / metadata.fps
                )

                results = detector.detect(
                    frame,
                    timestamp_ms,
                )

                if results.pose_landmarks:
                    detected_frames += 1

            detection_rate = (
                detected_frames
                / frame_number
                * 100
                if frame_number > 0
                else 0
            )

            print(
                f"Processed frames:      {frame_number}"
            )
            print(
                f"Frames with pose:      {detected_frames}"
            )
            print(
                f"Pose detection rate:   "
                f"{detection_rate:.2f}%"
            )

            if detected_frames == 0:
                print(
                    "Pose detection test: FAILED"
                )
                return

            print(
                "Pose detection test: PASSED"
            )


if __name__ == "__main__":
    main()