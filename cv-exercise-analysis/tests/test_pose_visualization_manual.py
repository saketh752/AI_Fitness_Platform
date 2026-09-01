from pathlib import Path

import cv2
import mediapipe as mp

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

OUTPUT_PATH = (
    PROJECT_ROOT
    / "videos"
    / "squat"
    / "squat_pose_preview.mp4"
)


def main():
    print("Creating pose visualization")
    print("=" * 50)
    print(f"Input:  {VIDEO_PATH}")
    print(f"Output: {OUTPUT_PATH}")
    print()

    with VideoProcessor(VIDEO_PATH) as video:
        metadata = video.get_metadata()

        # Process the complete video.
        max_frames = metadata.frame_count

        fourcc = cv2.VideoWriter_fourcc(*"mp4v")

        writer = cv2.VideoWriter(
            str(OUTPUT_PATH),
            fourcc,
            metadata.fps,
            (metadata.width, metadata.height),
        )

        if not writer.isOpened():
            raise RuntimeError(
                f"Could not create output video: {OUTPUT_PATH}"
            )

        with PoseDetector(str(MODEL_PATH)) as detector:

            processed_frames = 0
            detected_frames = 0

            while processed_frames < max_frames:
                frame = video.read_frame()

                if frame is None:
                    break

                timestamp_ms = int(
                    processed_frames
                    * 1000
                    / metadata.fps
                )

                results = detector.detect(
                    frame,
                    timestamp_ms,
                )

                if results.pose_landmarks:
                    detected_frames += 1

                    # Convert MediaPipe landmarks into
                    # the format expected by the drawing utility.
                    pose_landmarks = results.pose_landmarks[0]

                    landmark_list = mp.tasks.vision.PoseLandmarksConnections

                    # Draw landmarks and connections.
                    for connection in landmark_list.POSE_LANDMARKS:
                        start = pose_landmarks[connection.start]
                        end = pose_landmarks[connection.end]

                        start_x = int(start.x * metadata.width)
                        start_y = int(start.y * metadata.height)
                        end_x = int(end.x * metadata.width)
                        end_y = int(end.y * metadata.height)

                        cv2.line(
                            frame,
                            (start_x, start_y),
                            (end_x, end_y),
                            (0, 255, 0),
                            2,
                        )

                    for landmark in pose_landmarks:
                        x = int(landmark.x * metadata.width)
                        y = int(landmark.y * metadata.height)

                        cv2.circle(
                            frame,
                            (x, y),
                            4,
                            (0, 0, 255),
                            -1,
                        )

                writer.write(frame)
                processed_frames += 1

        writer.release()

    detection_rate = (
        detected_frames / processed_frames * 100
        if processed_frames > 0
        else 0
    )

    print(f"Processed frames:    {processed_frames}")
    print(f"Detected frames:     {detected_frames}")
    print(f"Detection rate:      {detection_rate:.2f}%")
    print()
    print(f"Output created:      {OUTPUT_PATH}")
    print("Visualization test:  PASSED")


if __name__ == "__main__":
    main()