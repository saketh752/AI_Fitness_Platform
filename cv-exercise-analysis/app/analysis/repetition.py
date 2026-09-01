from dataclasses import dataclass


@dataclass
class Repetition:
    """
    Represents one completed exercise repetition.
    """

    repetition_number: int

    start_frame: int
    bottom_frame: int
    end_frame: int

    start_timestamp_ms: int
    bottom_timestamp_ms: int
    end_timestamp_ms: int

    minimum_angle: float

    descent_duration_ms: int
    ascent_duration_ms: int
    total_duration_ms: int

    def to_dict(self) -> dict:
        return {
            "repetition_number": self.repetition_number,
            "start_frame": self.start_frame,
            "bottom_frame": self.bottom_frame,
            "end_frame": self.end_frame,
            "start_timestamp_ms": self.start_timestamp_ms,
            "bottom_timestamp_ms": self.bottom_timestamp_ms,
            "end_timestamp_ms": self.end_timestamp_ms,
            "minimum_angle": self.minimum_angle,
            "descent_duration_ms": self.descent_duration_ms,
            "ascent_duration_ms": self.ascent_duration_ms,
            "total_duration_ms": self.total_duration_ms,
        }