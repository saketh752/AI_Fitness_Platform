from dataclasses import dataclass


@dataclass
class PushupPhaseEvent:
    """
    Represents a detected push-up movement phase.
    """

    frame_index: int
    timestamp_ms: int
    elbow_angle: float
    phase: str


class PushupPhaseDetector:
    """
    Detect push-up movement phases from elbow angle.

    Basic movement:

        top
          ↓
        descending
          ↓
        bottom
          ↓
        ascending
          ↓
        top

    Elbow angle behavior:

        descending -> angle decreases
        ascending  -> angle increases
    """

    def __init__(
        self,
        top_threshold: float = 160.0,
        bottom_threshold: float = 100.0,
        tolerance: float = 1.0,
    ):
        self.top_threshold = top_threshold
        self.bottom_threshold = bottom_threshold
        self.tolerance = tolerance

        self.reset()

    def reset(self):
        """Reset detector state."""

        self.phase = "top"
        self.previous_angle = None

    def update(
        self,
        elbow_angle: float,
        frame_index: int,
        timestamp_ms: int,
        direction: str,
    ) -> PushupPhaseEvent | None:
        """
        Consume one elbow-angle measurement.

        Returns a PushupPhaseEvent when a meaningful
        phase transition is detected.
        """

        previous_phase = self.phase

        # --------------------------------------------------
        # TOP
        # --------------------------------------------------

        if elbow_angle >= self.top_threshold:

            if self.phase == "ascending":
                self.phase = "top"

            elif self.phase == "bottom":
                self.phase = "top"

            elif self.phase == "top":
                self.phase = "top"

        # --------------------------------------------------
        # DESCENDING
        # --------------------------------------------------

        elif (
            direction == "decreasing"
            and elbow_angle < self.top_threshold
        ):

            if self.phase == "top":
                self.phase = "descending"

        # --------------------------------------------------
        # BOTTOM
        # --------------------------------------------------

        if (
            elbow_angle <= self.bottom_threshold
            and self.phase == "descending"
        ):
            self.phase = "bottom"

        # --------------------------------------------------
        # ASCENDING
        # --------------------------------------------------

        elif (
            direction == "increasing"
            and self.phase == "bottom"
        ):
            self.phase = "ascending"

        # --------------------------------------------------
        # Generate event only when phase changes
        # --------------------------------------------------

        if self.phase != previous_phase:

            event = PushupPhaseEvent(
                frame_index=frame_index,
                timestamp_ms=timestamp_ms,
                elbow_angle=elbow_angle,
                phase=self.phase,
            )

            self.previous_angle = elbow_angle

            return event

        self.previous_angle = elbow_angle

        return None