from dataclasses import dataclass


@dataclass
class PhasePoint:
    """A detected movement phase point."""

    frame_index: int
    timestamp_ms: int
    value: float
    phase: str

    def to_dict(self) -> dict:
        return {
            "frame_index": self.frame_index,
            "timestamp_ms": self.timestamp_ms,
            "value": self.value,
            "phase": self.phase,
        }


def classify_direction(
    previous_value: float,
    current_value: float,
    tolerance: float = 1.0,
) -> str:
    """
    Classify movement direction.

    For squat knee angle:

    decreasing → descending
    increasing → ascending
    stable     → approximately stationary
    """

    difference = current_value - previous_value

    if difference > tolerance:
        return "increasing"

    if difference < -tolerance:
        return "decreasing"

    return "stable"


def detect_direction_changes(
    values: list[tuple[int, int, float]],
    tolerance: float = 1.0,
) -> list[PhasePoint]:
    """
    Detect points where the direction of movement changes.

    Input:
        (frame_index, timestamp_ms, value)

    Output:
        PhasePoint objects representing direction changes.
    """

    if len(values) < 2:
        return []

    directions = []

    for i in range(1, len(values)):
        previous_value = values[i - 1][2]
        current_value = values[i][2]

        direction = classify_direction(
            previous_value,
            current_value,
            tolerance,
        )

        directions.append(direction)

    changes = []

    previous_direction = directions[0]

    for i in range(1, len(directions)):

        current_direction = directions[i]

        if (
            current_direction != previous_direction
            and current_direction != "stable"
            and previous_direction != "stable"
        ):
            frame_index = values[i + 1][0]
            timestamp_ms = values[i + 1][1]
            value = values[i + 1][2]

            changes.append(
                PhasePoint(
                    frame_index=frame_index,
                    timestamp_ms=timestamp_ms,
                    value=value,
                    phase=(
                        f"{previous_direction}_to_"
                        f"{current_direction}"
                    ),
                )
            )

        if current_direction != "stable":
            previous_direction = current_direction

    return changes