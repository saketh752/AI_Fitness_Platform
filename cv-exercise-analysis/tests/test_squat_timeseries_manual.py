from pathlib import Path
import csv

from app.preprocessing.video_processor import VideoProcessor
from app.pose.detector import PoseDetector
from app.pose.landmarks import extract_landmarks
from app.analysis.joint_angles import (
    calculate_squat_joint_angles,
)
from app.analysis.temporal import FrameMeasurement


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
    / "data"
    / "analysis"
    / "squat_timeseries.csv"
)


def main():
    print("Generating squat movement time series")
    print("=" * 60)
    print()

    measurements = []

    with VideoProcessor(VIDEO_PATH) as video:
        metadata = video.get_metadata()

        print(f"Frames: {metadata.frame_count}")
        print(f"FPS:    {metadata.fps:.2f}")
        print(
            f"Duration: "
            f"{metadata.duration_seconds:.2f} seconds"
        )
        print()

        with PoseDetector(str(MODEL_PATH)) as detector:

            frame_index = 0
            pose_frames = 0

            while True:
                frame = video.read_frame()

                if frame is None:
                    break

                timestamp_ms = int(
                    frame_index * 1000 / metadata.fps
                )

                results = detector.detect(
                    frame,
                    timestamp_ms,
                )

                landmarks = extract_landmarks(
                    results
                )

                if landmarks:
                    angles = (
                        calculate_squat_joint_angles(
                            landmarks
                        )
                    )

                    measurement = FrameMeasurement(
                        frame_index=frame_index,
                        timestamp_ms=timestamp_ms,
                        values=angles,
                    )

                    measurements.append(
                        measurement
                    )

                    pose_frames += 1

                frame_index += 1

    print(f"Processed frames: {frame_index}")
    print(f"Frames with pose: {pose_frames}")
    print(
        f"Measurements:    {len(measurements)}"
    )

    if not measurements:
        print()
        print(
            "Time-series generation: FAILED"
        )
        return

    # --------------------------------------------------
    # Write CSV
    # --------------------------------------------------

    OUTPUT_PATH.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    fieldnames = [
        "frame_index",
        "timestamp_ms",
        "left_knee_2d",
        "right_knee_2d",
        "left_hip_2d",
        "right_hip_2d",
        "left_knee_3d",
        "right_knee_3d",
        "left_hip_3d",
        "right_hip_3d",
    ]

    with OUTPUT_PATH.open(
        "w",
        newline="",
        encoding="utf-8",
    ) as csv_file:

        writer = csv.DictWriter(
            csv_file,
            fieldnames=fieldnames,
        )

        writer.writeheader()

        for measurement in measurements:
            row = {
                "frame_index": (
                    measurement.frame_index
                ),
                "timestamp_ms": (
                    measurement.timestamp_ms
                ),
            }

            for field in fieldnames[2:]:
                row[field] = measurement.values[
                    field
                ]

            writer.writerow(row)

    # --------------------------------------------------
    # Basic signal statistics
    # --------------------------------------------------

    left_knee_values = [
        m.values["left_knee_2d"]
        for m in measurements
    ]

    right_knee_values = [
        m.values["right_knee_2d"]
        for m in measurements
    ]

    left_hip_values = [
        m.values["left_hip_2d"]
        for m in measurements
    ]

    right_hip_values = [
        m.values["right_hip_2d"]
        for m in measurements
    ]

    print()
    print("2D signal statistics")
    print("-" * 60)

    print(
        f"Left knee:   "
        f"min={min(left_knee_values):.2f}° "
        f"max={max(left_knee_values):.2f}°"
    )

    print(
        f"Right knee:  "
        f"min={min(right_knee_values):.2f}° "
        f"max={max(right_knee_values):.2f}°"
    )

    print(
        f"Left hip:    "
        f"min={min(left_hip_values):.2f}° "
        f"max={max(left_hip_values):.2f}°"
    )

    print(
        f"Right hip:   "
        f"min={min(right_hip_values):.2f}° "
        f"max={max(right_hip_values):.2f}°"
    )

    # --------------------------------------------------
    # Sample points for quick inspection
    # --------------------------------------------------

    print()
    print("Movement samples")
    print("-" * 60)

    sample_indices = [
        0,
        len(measurements) // 4,
        len(measurements) // 2,
        (len(measurements) * 3) // 4,
        len(measurements) - 1,
    ]

    for index in sample_indices:
        measurement = measurements[index]

        print(
            f"Frame {measurement.frame_index:4d} "
            f"({measurement.timestamp_ms / 1000:.2f}s): "
            f"L knee="
            f"{measurement.values['left_knee_2d']:.2f}° "
            f"R knee="
            f"{measurement.values['right_knee_2d']:.2f}°"
        )

    print()
    print(
        f"CSV created: {OUTPUT_PATH}"
    )
    print()
    print(
        "Squat time-series test: PASSED"
    )


if __name__ == "__main__":
    main()