from typing import Optional

from app.analysis.repetition import Repetition


class PushupRepetitionDetector:
    """
    Converts push-up phase events into completed repetitions.

    A repetition is completed after:

        top
          ↓
        descending
          ↓
        bottom
          ↓
        ascending
          ↓
        top
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
        Consume one PushupPhaseEvent.

        Returns a Repetition only when a complete
        push-up cycle returns to the top position.
        """

        if event is None:
            return None

        # ----------------------------------------------
        # TOP
        # ----------------------------------------------

        if event.phase == "top":

            if (
                self.start_event is not None
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

                self.start_event = None
                self.bottom_event = None
                self.ascending_event = None

                return repetition

        # ----------------------------------------------
        # DESCENDING
        # ----------------------------------------------

        elif event.phase == "descending":

            if self.start_event is None:
                self.start_event = event

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

        return None

    def get_repetitions(self):
        """Return completed repetitions."""
        return list(self.repetitions)