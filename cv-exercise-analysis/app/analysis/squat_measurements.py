from dataclasses import dataclass
from statistics import median
from typing import Sequence

from app.analysis.repetition import Repetition


@dataclass
class SquatMeasurements:
    """
    Objective measurements for one completed squat.

    The measurement layer does not decide whether form
    is good or bad. It provides reliable measurements
    for the form-analysis layer.

    Bottom-angle measurements are calculated from a
    time-based window around the detected bottom event.
    """

    repetition_number: int

    # --------------------------------------------------
    # Robust bottom measurements - 2D knee
    # --------------------------------------------------

    bottom_left_knee_angle: float
    bottom_right_knee_angle: float
    average_bottom_knee_angle: float
    knee_angle_asymmetry: float

    # --------------------------------------------------
    # Robust bottom measurements - 2D hip
    # --------------------------------------------------

    bottom_left_hip_angle: float
    bottom_right_hip_angle: float
    average_bottom_hip_angle: float
    hip_angle_asymmetry: float

    # --------------------------------------------------
    # 3D supporting measurements
    # --------------------------------------------------

    bottom_left_knee_angle_3d: float
    bottom_right_knee_angle_3d: float
    bottom_left_hip_angle_3d: float
    bottom_right_hip_angle_3d: float

    # --------------------------------------------------
    # Timing
    # --------------------------------------------------

    descent_duration_ms: int
    ascent_duration_ms: int
    total_duration_ms: int

    # --------------------------------------------------
    # Diagnostic information
    # --------------------------------------------------

    bottom_window_start_ms: int
    bottom_window_end_ms: int
    bottom_sample_count: int

    def to_dict(self) -> dict:
        """
        Convert measurements into a JSON-friendly dictionary.
        """

        return {
            "repetition_number": self.repetition_number,

            "knee": {
                "bottom_left_angle": (
                    self.bottom_left_knee_angle
                ),
                "bottom_right_angle": (
                    self.bottom_right_knee_angle
                ),
                "average_bottom_angle": (
                    self.average_bottom_knee_angle
                ),
                "asymmetry": (
                    self.knee_angle_asymmetry
                ),
            },

            "hip": {
                "bottom_left_angle": (
                    self.bottom_left_hip_angle
                ),
                "bottom_right_angle": (
                    self.bottom_right_hip_angle
                ),
                "average_bottom_angle": (
                    self.average_bottom_hip_angle
                ),
                "asymmetry": (
                    self.hip_angle_asymmetry
                ),
            },

            "knee_3d": {
                "bottom_left_angle": (
                    self.bottom_left_knee_angle_3d
                ),
                "bottom_right_angle": (
                    self.bottom_right_knee_angle_3d
                ),
            },

            "hip_3d": {
                "bottom_left_angle": (
                    self.bottom_left_hip_angle_3d
                ),
                "bottom_right_angle": (
                    self.bottom_right_hip_angle_3d
                ),
            },

            "timing": {
                "descent_duration_ms": (
                    self.descent_duration_ms
                ),
                "ascent_duration_ms": (
                    self.ascent_duration_ms
                ),
                "total_duration_ms": (
                    self.total_duration_ms
                ),
            },

            "bottom_window": {
                "start_ms": (
                    self.bottom_window_start_ms
                ),
                "end_ms": (
                    self.bottom_window_end_ms
                ),
                "sample_count": (
                    self.bottom_sample_count
                ),
            },
        }


def _median(values: Sequence[float]) -> float:
    """
    Calculate the median of a non-empty sequence.
    """

    if not values:
        raise ValueError(
            "Cannot calculate median of empty values"
        )

    return float(median(values))


def _average(a: float, b: float) -> float:
    """
    Calculate the average of two values.
    """

    return (a + b) / 2.0


def _asymmetry(a: float, b: float) -> float:
    """
    Calculate absolute left/right asymmetry.
    """

    return abs(a - b)


def _bottom_window_rows(
    repetition: Repetition,
    rows: Sequence[dict],
    window_ms: int,
) -> list[dict]:
    """
    Select time-series rows inside a symmetric temporal
    window around the detected bottom event.
    """

    if window_ms <= 0:
        raise ValueError(
            "window_ms must be greater than zero"
        )

    bottom_time = repetition.bottom_timestamp_ms

    start_time = bottom_time - window_ms
    end_time = bottom_time + window_ms

    result = []

    for row in rows:
        timestamp = int(row["timestamp_ms"])

        if start_time <= timestamp <= end_time:
            result.append(row)

    return result


def calculate_squat_measurements(
    repetition: Repetition,
    rows: Sequence[dict],
    bottom_window_ms: int = 150,
) -> SquatMeasurements:
    """
    Calculate robust squat measurements around the
    detected bottom event.

    A ±bottom_window_ms temporal window is used around
    repetition.bottom_timestamp_ms.

    Median values are used instead of absolute minima
    so isolated pose/geometry artifacts do not dominate
    the measurement.
    """

    if not rows:
        raise ValueError(
            "No time-series rows supplied"
        )

    # --------------------------------------------------
    # Select bottom measurement window
    # --------------------------------------------------

    window_rows = _bottom_window_rows(
        repetition=repetition,
        rows=rows,
        window_ms=bottom_window_ms,
    )

    if not window_rows:
        raise ValueError(
            "No rows found inside bottom measurement window"
        )

    # --------------------------------------------------
    # Extract 2D knee angles
    # --------------------------------------------------

    left_knee_2d = [
        float(row["left_knee_2d"])
        for row in window_rows
    ]

    right_knee_2d = [
        float(row["right_knee_2d"])
        for row in window_rows
    ]

    # --------------------------------------------------
    # Extract 2D hip angles
    # --------------------------------------------------

    left_hip_2d = [
        float(row["left_hip_2d"])
        for row in window_rows
    ]

    right_hip_2d = [
        float(row["right_hip_2d"])
        for row in window_rows
    ]

    # --------------------------------------------------
    # Extract 3D knee angles
    # --------------------------------------------------

    left_knee_3d = [
        float(row["left_knee_3d"])
        for row in window_rows
    ]

    right_knee_3d = [
        float(row["right_knee_3d"])
        for row in window_rows
    ]

    # --------------------------------------------------
    # Extract 3D hip angles
    # --------------------------------------------------

    left_hip_3d = [
        float(row["left_hip_3d"])
        for row in window_rows
    ]

    right_hip_3d = [
        float(row["right_hip_3d"])
        for row in window_rows
    ]

    # --------------------------------------------------
    # Robust 2D knee measurements
    # --------------------------------------------------

    bottom_left_knee = _median(
        left_knee_2d
    )

    bottom_right_knee = _median(
        right_knee_2d
    )

    average_bottom_knee = _average(
        bottom_left_knee,
        bottom_right_knee,
    )

    knee_asymmetry = _asymmetry(
        bottom_left_knee,
        bottom_right_knee,
    )

    # --------------------------------------------------
    # Robust 2D hip measurements
    # --------------------------------------------------

    bottom_left_hip = _median(
        left_hip_2d
    )

    bottom_right_hip = _median(
        right_hip_2d
    )

    average_bottom_hip = _average(
        bottom_left_hip,
        bottom_right_hip,
    )

    hip_asymmetry = _asymmetry(
        bottom_left_hip,
        bottom_right_hip,
    )

    # --------------------------------------------------
    # Robust 3D supporting measurements
    # --------------------------------------------------

    bottom_left_knee_3d = _median(
        left_knee_3d
    )

    bottom_right_knee_3d = _median(
        right_knee_3d
    )

    bottom_left_hip_3d = _median(
        left_hip_3d
    )

    bottom_right_hip_3d = _median(
        right_hip_3d
    )

    # --------------------------------------------------
    # Bottom window boundaries
    # --------------------------------------------------

    bottom_window_start_ms = (
        repetition.bottom_timestamp_ms
        - bottom_window_ms
    )

    bottom_window_end_ms = (
        repetition.bottom_timestamp_ms
        + bottom_window_ms
    )

    # --------------------------------------------------
    # Build measurement object
    # --------------------------------------------------

    return SquatMeasurements(
        repetition_number=(
            repetition.repetition_number
        ),

        bottom_left_knee_angle=(
            bottom_left_knee
        ),

        bottom_right_knee_angle=(
            bottom_right_knee
        ),

        average_bottom_knee_angle=(
            average_bottom_knee
        ),

        knee_angle_asymmetry=(
            knee_asymmetry
        ),

        bottom_left_hip_angle=(
            bottom_left_hip
        ),

        bottom_right_hip_angle=(
            bottom_right_hip
        ),

        average_bottom_hip_angle=(
            average_bottom_hip
        ),

        hip_angle_asymmetry=(
            hip_asymmetry
        ),

        bottom_left_knee_angle_3d=(
            bottom_left_knee_3d
        ),

        bottom_right_knee_angle_3d=(
            bottom_right_knee_3d
        ),

        bottom_left_hip_angle_3d=(
            bottom_left_hip_3d
        ),

        bottom_right_hip_angle_3d=(
            bottom_right_hip_3d
        ),

        descent_duration_ms=(
            repetition.descent_duration_ms
        ),

        ascent_duration_ms=(
            repetition.ascent_duration_ms
        ),

        total_duration_ms=(
            repetition.total_duration_ms
        ),

        bottom_window_start_ms=(
            bottom_window_start_ms
        ),

        bottom_window_end_ms=(
            bottom_window_end_ms
        ),

        bottom_sample_count=len(
            window_rows
        ),
    )