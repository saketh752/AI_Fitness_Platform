from dataclasses import dataclass, field


@dataclass
class FrameMeasurement:
    """Measurements produced for a single video frame."""

    frame_index: int
    timestamp_ms: int

    values: dict[str, float] = field(default_factory=dict)

    def get(self, name: str) -> float | None:
        """Return a measurement by name."""
        return self.values.get(name)

    def to_dict(self) -> dict:
        """Convert the measurement to a JSON-compatible dictionary."""
        return {
            "frame_index": self.frame_index,
            "timestamp_ms": self.timestamp_ms,
            "values": self.values,
        }


@dataclass
class MovementSample:
    """A single point in a movement time series."""

    timestamp_ms: int
    value: float


def calculate_movement_direction(
    previous_value: float,
    current_value: float,
    tolerance: float = 0.5,
) -> str:
    """
    Determine whether a measurement is increasing,
    decreasing, or approximately stable.

    The tolerance prevents tiny frame-to-frame
    fluctuations from being treated as movement.
    """

    difference = current_value - previous_value

    if difference > tolerance:
        return "increasing"

    if difference < -tolerance:
        return "decreasing"

    return "stable"