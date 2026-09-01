from dataclasses import dataclass


@dataclass
class BicepPhaseEvent:
    """
    Represents a detected bicep-curl movement phase.
    """

    frame_index: int
    timestamp_ms: int
    elbow_angle: float
    phase: str


class BicepPhaseDetector:
    """
    Detect bicep-curl movement phases from elbow angle.

    Basic movement:

        top
          ↓
        ascending
          ↓
        bottom
          ↓
        descending
          ↓
        top

    Elbow angle behavior:

        ascending -> angle decreases
        descending -> angle increases
    """

    def __init__(
        self,
        top_threshold: float = 150.0,
        bottom_threshold: float = 60.0,
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
    ) -> BicepPhaseEvent | None:
        """
        Consume one elbow-angle measurement.

        Returns a BicepPhaseEvent when a meaningful
        phase transition is detected.
        """

        previous_phase = self.phase

        # --------------------------------------------------
        # TOP
        # --------------------------------------------------

        if elbow_angle >= self.top_threshold:

            if self.phase == "descending":
                self.phase = "top"

            elif self.phase == "top":
                self.phase = "top"

        # --------------------------------------------------
        # ASCENDING
        # --------------------------------------------------

        elif (
            direction == "decreasing"
            and elbow_angle < self.top_threshold
        ):

            if self.phase == "top":
                self.phase = "ascending"

        # --------------------------------------------------
        # BOTTOM
        # --------------------------------------------------

        if (
            elbow_angle <= self.bottom_threshold
            and self.phase == "ascending"
        ):
            self.phase = "bottom"

        # --------------------------------------------------
        # DESCENDING
        # --------------------------------------------------

        elif (
            direction == "increasing"
            and self.phase == "bottom"
        ):
            self.phase = "descending"

        # --------------------------------------------------
        # TOP RECOVERY
        #
        # Real videos can contain noisy pose frames.
        #
        # Once the movement has entered descending,
        # allow a clean top-angle observation to finish
        # the movement.
        # --------------------------------------------------

        elif (
            self.phase == "descending"
            and elbow_angle >= (
                self.top_threshold - self.tolerance
            )
        ):
            self.phase = "top"

        # --------------------------------------------------
        # Generate event only when phase changes
        # --------------------------------------------------

        if self.phase != previous_phase:

            event = BicepPhaseEvent(
                frame_index=frame_index,
                timestamp_ms=timestamp_ms,
                elbow_angle=elbow_angle,
                phase=self.phase,
            )

            self.previous_angle = elbow_angle

            return event

        self.previous_angle = elbow_angle

        return None