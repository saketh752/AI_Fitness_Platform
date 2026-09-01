from dataclasses import dataclass
from typing import Any


@dataclass
class PushupMeasurements:
    """
    Measurements calculated for one completed push-up repetition.
    """

    repetition_number: int

    average_bottom_elbow_angle: float
    average_top_elbow_angle: float

    body_line_angle: float

    elbow_symmetry: float

    descent_duration_ms: int
    ascent_duration_ms: int
    total_duration_ms: int

    def to_dict(self) -> dict[str, Any]:
        return {
            "repetition_number": self.repetition_number,

            "elbow": {
                "average_bottom": (
                    self.average_bottom_elbow_angle
                ),
                "average_top": (
                    self.average_top_elbow_angle
                ),
            },

            "body_line_angle": self.body_line_angle,

            "elbow_symmetry": self.elbow_symmetry,

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
        }