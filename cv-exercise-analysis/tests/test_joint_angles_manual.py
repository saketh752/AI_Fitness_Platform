from pathlib import Path

from app.preprocessing.video_processor import VideoProcessor
from app.pose.detector import PoseDetector
from app.pose.landmarks import extract_landmarks
from app.analysis.joint_angles import (
    calculate_squat_joint_angles,
)


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
    print("Testing joint angle analysis")
    print("=" * 60)
    print()

    with VideoProcessor(VIDEO_PATH) as video:
        metadata = video.get_metadata()

        sample_count = 10

        # Select 10 evenly distributed frame numbers.
        sample_indices = [
            int(
                i * (metadata.frame_count - 1)
                / (sample_count - 1)
            )
            for i in range(sample_count)
        ]

        sample_index_set = set(sample_indices)

        results = []

        with PoseDetector(str(MODEL_PATH)) as detector:

            frame_index = 0

            while True:

                frame = video.read_frame()

                if frame is None:
                    break

                if frame_index in sample_index_set:

                    timestamp_ms = int(
                        frame_index * 1000 / metadata.fps
                    )

                    pose_result = detector.detect(
                        frame,
                        timestamp_ms,
                    )

                    landmarks = extract_landmarks(
                        pose_result
                    )

                    if not landmarks:
                        print(
                            f"Frame {frame_index}: "
                            f"NO POSE"
                        )
                    else:
                        angles = (
                            calculate_squat_joint_angles(
                                landmarks
                            )
                        )

                        results.append(
                            (frame_index, angles)
                        )

                frame_index += 1

    print(
        f"Sampled frames with pose: "
        f"{len(results)}/{sample_count}"
    )
    print()

    print("Joint angles across movement")
    print("-" * 60)

    for frame_index, angles in results:

        print(f"\nFrame {frame_index:4d}")

        print(
            f"  Left knee:  "
            f"{angles['left_knee_2d']:7.2f}°  "
            f"(3D: "
            f"{angles['left_knee_3d']:7.2f}°)"
        )

        print(
            f"  Right knee: "
            f"{angles['right_knee_2d']:7.2f}°  "
            f"(3D: "
            f"{angles['right_knee_3d']:7.2f}°)"
        )

        print(
            f"  Left hip:   "
            f"{angles['left_hip_2d']:7.2f}°  "
            f"(3D: "
            f"{angles['left_hip_3d']:7.2f}°)"
        )

        print(
            f"  Right hip:  "
            f"{angles['right_hip_2d']:7.2f}°  "
            f"(3D: "
            f"{angles['right_hip_3d']:7.2f}°)"
        )

    print()

    if len(results) != sample_count:
        print("Joint angle test: FAILED")
        return

    print("Joint angle test: PASSED")


if __name__ == "__main__":
    main()