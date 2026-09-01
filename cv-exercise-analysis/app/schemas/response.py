from dataclasses import dataclass, field
from typing import Any


@dataclass
class FeedbackResponse:
    """
    User-facing feedback for one repetition.
    """

    repetition_number: int
    feedback: list[str] = field(
        default_factory=list
    )

    def to_dict(self) -> dict:
        return {
            "repetition_number": self.repetition_number,
            "feedback": self.feedback,
        }


@dataclass
class CVAnalysisResponse:
    """
    Final CV response contract.

    This is intentionally independent of Flutter
    and the backend.
    """

    exercise: str
    total_repetitions: int
    repetitions: list[dict[str, Any]] = field(
        default_factory=list
    )

    def to_dict(self) -> dict:
        return {
            "exercise": self.exercise,
            "total_repetitions": self.total_repetitions,
            "repetitions": self.repetitions,
        }