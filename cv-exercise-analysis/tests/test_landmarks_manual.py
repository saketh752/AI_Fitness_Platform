from pathlib import Path

from app.preprocessing.video_processor import VideoProcessor
from app.pose.detector import PoseDetector
from app.pose.landmarks import extract_landmarks


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
    print("Testing landmark extraction")
    print("=" * 50)
    print()

    with VideoProcessor(VIDEO_PATH) as video:
        metadata = video.get_metadata()

        # Read the first frame
        frame = video.read_frame()

        if frame is None:
            print("ERROR: Could not read first frame.")
            return

        timestamp_ms = 0

        with PoseDetector(str(MODEL_PATH)) as detector:
            results = detector.detect(
                frame,
                timestamp_ms,
            )

            landmarks = extract_landmarks(results)

    if not landmarks:
        print("ERROR: No landmarks extracted.")
        return

    print(f"Landmarks detected: {len(landmarks)}")
    print()

    print("Selected landmarks")
    print("-" * 50)

    selected_names = {
        "left_shoulder",
        "right_shoulder",
        "left_hip",
        "right_hip",
        "left_knee",
        "right_knee",
        "left_ankle",
        "right_ankle",
    }

    for landmark in landmarks:
        if landmark.name in selected_names:
            print(
                f"{landmark.name:15} "
                f"image=({landmark.x:.4f}, "
                f"{landmark.y:.4f}, "
                f"{landmark.z:.4f}) "
                f"world=({landmark.world_x:.4f}, "
                f"{landmark.world_y:.4f}, "
                f"{landmark.world_z:.4f}) "
                f"visibility={landmark.visibility:.4f}"
            )

    print()

    # Verify JSON-compatible conversion
    landmark_dict = landmarks[0].to_dict()

    print("Dictionary conversion: PASSED")
    print(
        f"First landmark keys: "
        f"{list(landmark_dict.keys())}"
    )

    if len(landmarks) != 33:
        print(
            f"WARNING: Expected 33 landmarks, "
            f"got {len(landmarks)}"
        )
    else:
        print("33-landmark validation: PASSED")

    print()
    print("Landmark extraction test: PASSED")


if __name__ == "__main__":
    main()