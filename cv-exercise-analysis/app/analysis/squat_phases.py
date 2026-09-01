from dataclasses import dataclass


@dataclass
class SquatPhaseEvent:
    frame_index: int
    timestamp_ms: int
    angle: float
    phase: str

    def to_dict(self) -> dict:
        return {
            "frame_index": self.frame_index,
            "timestamp_ms": self.timestamp_ms,
            "angle": self.angle,
            "phase": self.phase,
        }


class SquatPhaseDetector:
    """
    Rule-based squat movement phase detector.

    State flow:

        STANDING
            ↓
        DESCENDING
            ↓
          BOTTOM
            ↓
         ASCENDING
            ↓
        STANDING
    """

    STANDING_THRESHOLD = 160.0
    DEPTH_THRESHOLD = 100.0

    def __init__(
        self,
        standing_threshold: float = STANDING_THRESHOLD,
        depth_threshold: float = DEPTH_THRESHOLD,
    ):
        self.standing_threshold = (
            standing_threshold
        )

        self.depth_threshold = (
            depth_threshold
        )

        self.state = "STANDING"

        self.bottom_seen = False

    def reset(self):
        self.state = "STANDING"
        self.bottom_seen = False

    def update(
        self,
        angle: float,
        frame_index: int,
        timestamp_ms: int,
        direction: str,
    ):
        """
        Update the detector with one frame.

        Returns a SquatPhaseEvent when a meaningful
        state transition occurs, otherwise None.
        """

        # --------------------------------------------------
        # STANDING → DESCENDING
        # --------------------------------------------------

        if self.state == "STANDING":

            if (
                direction == "decreasing"
                and angle < self.standing_threshold
            ):
                self.state = "DESCENDING"

                return SquatPhaseEvent(
                    frame_index,
                    timestamp_ms,
                    angle,
                    "descending",
                )

        # --------------------------------------------------
        # DESCENDING → BOTTOM
        # --------------------------------------------------

        elif self.state == "DESCENDING":

            if angle <= self.depth_threshold:
                self.state = "BOTTOM"
                self.bottom_seen = True

                return SquatPhaseEvent(
                    frame_index,
                    timestamp_ms,
                    angle,
                    "bottom",
                )

        # --------------------------------------------------
        # BOTTOM → ASCENDING
        # --------------------------------------------------

        elif self.state == "BOTTOM":

            if direction == "increasing":

                self.state = "ASCENDING"

                return SquatPhaseEvent(
                    frame_index,
                    timestamp_ms,
                    angle,
                    "ascending",
                )

        # --------------------------------------------------
        # ASCENDING → STANDING
        # --------------------------------------------------

        elif self.state == "ASCENDING":

            if angle >= self.standing_threshold:

                self.state = "STANDING"

                return SquatPhaseEvent(
                    frame_index,
                    timestamp_ms,
                    angle,
                    "standing",
                )

        return None