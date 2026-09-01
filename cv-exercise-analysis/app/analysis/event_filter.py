from dataclasses import dataclass


@dataclass
class MovementEvent:
    """A meaningful movement turning point."""

    frame_index: int
    timestamp_ms: int
    value: float
    event_type: str

    def to_dict(self) -> dict:
        return {
            "frame_index": self.frame_index,
            "timestamp_ms": self.timestamp_ms,
            "value": self.value,
            "event_type": self.event_type,
        }


def filter_events(
    events,
    min_frames_between: int = 15,
    min_value_change: float = 10.0,
):
    """
    Filter noisy movement events.

    An event is retained only when:

    1. It is sufficiently far from the previous
       accepted event.
    2. Its value differs sufficiently from the
       previous accepted event.

    Parameters
    ----------
    events:
        Iterable of PhasePoint-like objects.

    min_frames_between:
        Minimum number of frames between accepted
        events.

    min_value_change:
        Minimum absolute value difference between
        accepted events.
    """

    if not events:
        return []

    filtered = []

    for event in events:

        if not filtered:
            filtered.append(event)
            continue

        previous = filtered[-1]

        frame_distance = (
            event.frame_index
            - previous.frame_index
        )

        value_change = abs(
            event.value - previous.value
        )

        if frame_distance < min_frames_between:
            continue

        if value_change < min_value_change:
            continue

        filtered.append(event)

    return filtered