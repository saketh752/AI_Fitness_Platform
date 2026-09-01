from pathlib import Path
import csv

from app.analysis.repetition import Repetition
from app.analysis.squat_measurements import (
    calculate_squat_measurements,
)


BASE_DIR = Path(__file__).resolve().parents[1]

CSV_PATH = (
    BASE_DIR
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


def load_rows(path: Path) -> list[dict]:
    with path.open(
        "r",
        newline="",
        encoding="utf-8",
    ) as file:
        reader = csv.DictReader(file)
        return list(reader)


def build_test_repetition(rows: list[dict]) -> Repetition:
    """
    Build the first known complete squat repetition
    from the validated real-video phase boundaries.
    """

    start_frame = 33
    bottom_frame = 256
    end_frame = 334

    start_row = rows[start_frame]
    bottom_row = rows[bottom_frame]
    end_row = rows[end_frame]

    start_timestamp_ms = int(
        start_row["timestamp_ms"]
    )

    bottom_timestamp_ms = int(
        bottom_row["timestamp_ms"]
    )

    end_timestamp_ms = int(
        end_row["timestamp_ms"]
    )

    return Repetition(
        repetition_number=1,

        start_frame=start_frame,
        bottom_frame=bottom_frame,
        end_frame=end_frame,

        start_timestamp_ms=start_timestamp_ms,
        bottom_timestamp_ms=bottom_timestamp_ms,
        end_timestamp_ms=end_timestamp_ms,

        minimum_angle=float(
            bottom_row["left_knee_2d_smoothed"]
        ),

        descent_duration_ms=(
            bottom_timestamp_ms
            - start_timestamp_ms
        ),

        ascent_duration_ms=(
            end_timestamp_ms
            - bottom_timestamp_ms
        ),

        total_duration_ms=(
            end_timestamp_ms
            - start_timestamp_ms
        ),
    )


def main():
    print(
        "Testing squat measurement engine"
    )
    print("=" * 70)

    # --------------------------------------------------
    # Load time series
    # --------------------------------------------------

    rows = load_rows(CSV_PATH)

    print()
    print(f"Rows loaded: {len(rows)}")

    assert len(rows) > 0

    # --------------------------------------------------
    # Build validated repetition
    # --------------------------------------------------

    repetition = build_test_repetition(rows)

    # --------------------------------------------------
    # Calculate measurements
    # --------------------------------------------------

    measurements = calculate_squat_measurements(
        repetition=repetition,
        rows=rows,
        bottom_window_ms=150,
    )

    print(
        f"Bottom window: "
        f"{measurements.bottom_window_start_ms}"
        f" → "
        f"{measurements.bottom_window_end_ms} ms"
    )

    print(
        f"Bottom samples: "
        f"{measurements.bottom_sample_count}"
    )

    print("-" * 70)

    print(
        f"Repetition: "
        f"{measurements.repetition_number}"
    )

    # --------------------------------------------------
    # Knee measurements
    # --------------------------------------------------

    print()
    print("2D knee")

    print(
        "  Left bottom:   "
        f"{measurements.bottom_left_knee_angle:.2f}°"
    )

    print(
        "  Right bottom:  "
        f"{measurements.bottom_right_knee_angle:.2f}°"
    )

    print(
        "  Average:       "
        f"{measurements.average_bottom_knee_angle:.2f}°"
    )

    print(
        "  Asymmetry:     "
        f"{measurements.knee_angle_asymmetry:.2f}°"
    )

    # --------------------------------------------------
    # Hip measurements
    # --------------------------------------------------

    print()
    print("2D hip")

    print(
        "  Left bottom:   "
        f"{measurements.bottom_left_hip_angle:.2f}°"
    )

    print(
        "  Right bottom:  "
        f"{measurements.bottom_right_hip_angle:.2f}°"
    )

    print(
        "  Average:       "
        f"{measurements.average_bottom_hip_angle:.2f}°"
    )

    print(
        "  Asymmetry:     "
        f"{measurements.hip_angle_asymmetry:.2f}°"
    )

    # --------------------------------------------------
    # 3D supporting measurements
    # --------------------------------------------------

    print()
    print("3D supporting measurements")

    print(
        "  Left knee:      "
        f"{measurements.bottom_left_knee_angle_3d:.2f}°"
    )

    print(
        "  Right knee:     "
        f"{measurements.bottom_right_knee_angle_3d:.2f}°"
    )

    print(
        "  Left hip:       "
        f"{measurements.bottom_left_hip_angle_3d:.2f}°"
    )

    print(
        "  Right hip:      "
        f"{measurements.bottom_right_hip_angle_3d:.2f}°"
    )

    # --------------------------------------------------
    # Timing
    # --------------------------------------------------

    print()
    print("Timing")

    print(
        "  Descent: "
        f"{measurements.descent_duration_ms} ms"
    )

    print(
        "  Ascent:  "
        f"{measurements.ascent_duration_ms} ms"
    )

    print(
        "  Total:   "
        f"{measurements.total_duration_ms} ms"
    )

    # --------------------------------------------------
    # Validation
    # --------------------------------------------------

    assert (
        measurements.repetition_number == 1
    )

    assert (
        measurements.bottom_sample_count > 0
    )

    assert (
        measurements.bottom_window_start_ms
        < repetition.bottom_timestamp_ms
    )

    assert (
        measurements.bottom_window_end_ms
        > repetition.bottom_timestamp_ms
    )

    assert (
        measurements.bottom_left_knee_angle
        > 0
    )

    assert (
        measurements.bottom_right_knee_angle
        > 0
    )

    assert (
        measurements.average_bottom_knee_angle
        > 0
    )

    assert (
        measurements.knee_angle_asymmetry
        >= 0
    )

    assert (
        measurements.bottom_left_hip_angle
        > 0
    )

    assert (
        measurements.bottom_right_hip_angle
        > 0
    )

    assert (
        measurements.average_bottom_hip_angle
        > 0
    )

    assert (
        measurements.hip_angle_asymmetry
        >= 0
    )

    assert (
        measurements.descent_duration_ms
        > 0
    )

    assert (
        measurements.ascent_duration_ms
        > 0
    )

    assert (
        measurements.total_duration_ms
        > 0
    )

    print()
    print(
        "Measurement validation: PASSED"
    )

    # --------------------------------------------------
    # Dictionary conversion
    # --------------------------------------------------

    result = measurements.to_dict()

    assert isinstance(result, dict)
    assert result["repetition_number"] == 1

    assert "knee" in result
    assert "hip" in result
    assert "knee_3d" in result
    assert "hip_3d" in result
    assert "timing" in result
    assert "bottom_window" in result

    assert (
        "bottom_left_angle"
        in result["knee"]
    )

    assert (
        "average_bottom_angle"
        in result["knee"]
    )

    assert (
        "bottom_left_angle"
        in result["hip"]
    )

    print(
        "Dictionary conversion: PASSED"
    )

    print()
    print(
        "Squat measurement test: PASSED"
    )


if __name__ == "__main__":
    main()