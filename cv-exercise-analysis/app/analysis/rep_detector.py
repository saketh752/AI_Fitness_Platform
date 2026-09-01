from typing import Optional

from app.analysis.repetition import Repetition


class SquatRepetitionDetector:
    """
    Converts squat phase events into completed repetitions.

    A repetition is completed only after:

        descending
            ↓
        bottom
            ↓
        ascending
            ↓
        standing
    """

    def __init__(self):
        self.reset()

    def reset(self):
        self.start_event = None
        self.bottom_event = None
        self.ascending_event = None
        self.repetitions = []

    def update(self, event) -> Optional[Repetition]:
        """
        Consume one SquatPhaseEvent.

        Returns a Repetition only when a complete
        squat cycle reaches standing again.
        """

        if event is None:
            return None

        # ----------------------------------------------
        # DESCENDING
        # ----------------------------------------------

        if event.phase == "descending":

            # Start a new movement.
            self.start_event = event
            self.bottom_event = None
            self.ascending_event = None

        # ----------------------------------------------
        # BOTTOM
        # ----------------------------------------------

        elif (
            event.phase == "bottom"
            and self.start_event is not None
        ):

            self.bottom_event = event

        # ----------------------------------------------
        # ASCENDING
        # ----------------------------------------------

        elif (
            event.phase == "ascending"
            and self.bottom_event is not None
        ):

            self.ascending_event = event

        # ----------------------------------------------
        # STANDING
        # ----------------------------------------------

        elif (
            event.phase == "standing"
            and self.start_event is not None
            and self.bottom_event is not None
            and self.ascending_event is not None
        ):

            repetition_number = (
                len(self.repetitions) + 1
            )

            repetition = Repetition(
                repetition_number=repetition_number,

                start_frame=self.start_event.frame_index,
                bottom_frame=self.bottom_event.frame_index,
                end_frame=event.frame_index,

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
                    self.bottom_event.angle
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

            # Reset movement state while preserving
            # the completed repetition history.
            self.start_event = None
            self.bottom_event = None
            self.ascending_event = None

            return repetition

        return None

    def get_repetitions(self):
        return list(self.repetitions)