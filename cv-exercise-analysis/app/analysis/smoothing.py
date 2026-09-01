from collections import deque


class MovingAverageSmoother:
    """
    Simple moving-average smoother for time-series values.

    The smoother maintains a fixed-size window and returns
    the average of the values currently in that window.
    """

    def __init__(self, window_size: int = 5):
        if window_size < 1:
            raise ValueError(
                "window_size must be at least 1"
            )

        self.window_size = window_size
        self._values = deque(maxlen=window_size)

    def update(self, value: float) -> float:
        """
        Add a new value and return the current smoothed value.
        """

        self._values.append(value)

        return sum(self._values) / len(self._values)

    def reset(self) -> None:
        """Clear the smoothing window."""

        self._values.clear()

    @property
    def ready(self) -> bool:
        """
        Return True when the smoothing window is full.
        """

        return len(self._values) == self.window_size