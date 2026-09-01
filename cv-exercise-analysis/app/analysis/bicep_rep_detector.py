from typing import Optional

from app.analysis.repetition import Repetition


class BicepRepetitionDetector:
    """
    Converts bicep-curl phase events into completed repetitions.

    A repetition follows:

        ascending
            ↓
        bottom
            ↓
        descending
            ↓
        top

    The first ascending event marks the start of the repetition.
    """

    def __init__(self):
        self.reset()

    def reset(self):
        """Reset repetition detector state."""

        self.start_event = None
        self.bottom_event = None
        self.descending_event = None

        self.repetitions = []

    def update(
        self,
        event,
    ) -> Optional[Repetition]:
        """
        Consume one BicepPhaseEvent.

        Returns a Repetition only when the movement
        returns to the top position.
        """

        if event is None:
            return None

        # --------------------------------------------------
        # ASCENDING
        # --------------------------------------------------

        if event.phase == "ascending":

            # Start only if a repetition is not already active.
            if self.start_event is None:

                self.start_event = event

                # Clear stale state.
                self.bottom_event = None
                self.descending_event = None

            return None

        # --------------------------------------------------
        # BOTTOM
        # --------------------------------------------------

        if event.phase == "bottom":

            if self.start_event is not None:

                self.bottom_event = event

            return None

        # --------------------------------------------------
        # DESCENDING
        # --------------------------------------------------

        if event.phase == "descending":

            if (
                self.start_event is not None
                and self.bottom_event is not None
            ):

                self.descending_event = event

            return None

        # --------------------------------------------------
        # TOP
        # --------------------------------------------------

        if event.phase == "top":

            if (
                self.start_event is not None
                and self.bottom_event is not None
                and self.descending_event is not None
            ):

                repetition_number = (
                    len(self.repetitions) + 1
                )

                repetition = Repetition(
                    repetition_number=repetition_number,

                    start_frame=(
                        self.start_event.frame_index
                    ),

                    bottom_frame=(
                        self.bottom_event.frame_index
                    ),

                    end_frame=(
                        event.frame_index
                    ),

                    start_timestamp_ms=(
                        self.start_event.timestamp_ms
                    ),

                    bottom_timestamp_ms=(
                        self.bottom_event.timestamp_ms
                    ),

                    end_timestamp_ms=(
                        event.timestamp_ms
                    ),

                    minimum_angle=(
                        self.bottom_event.elbow_angle
                    ),

                    descent_duration_ms=(
                        self.bottom_event.timestamp_ms
                        - self.start_event.timestamp_ms
                    ),

                    ascent_duration_ms=(
                        event.timestamp_ms
                        - self.bottom_event.timestamp_ms
                    ),

                    total_duration_ms=(
                        event.timestamp_ms
                        - self.start_event.timestamp_ms
                    ),
                )

                self.repetitions.append(
                    repetition
                )

                # Reset active repetition.
                self.start_event = None
                self.bottom_event = None
                self.descending_event = None

                return repetition

        return None

    def get_repetitions(self):
        """Return completed repetitions."""

        return list(self.repetitions)