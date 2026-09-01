from dataclasses import dataclass, field
from typing import Any


@dataclass
class RepetitionAnalysis:
    """
    Combined analysis for one completed repetition.

    Contains:
        - repetition timing and movement data
        - calculated measurements
        - rule-based form analysis
        - user-facing coaching feedback
    """

    repetition_number: int
    repetition: Any
    measurements: Any
    form_analysis: Any
    feedback: list[Any] = field(
        default_factory=list
    )

    def to_dict(self) -> dict:
        return {
            "repetition_number": self.repetition_number,

            "repetition": (
                self.repetition.to_dict()
            ),

            "measurements": (
                self.measurements.to_dict()
            ),

            "form_analysis": (
                self.form_analysis.to_dict()
            ),

            "feedback": [
                item.to_dict()
                for item in self.feedback
            ],
        }


@dataclass
class ExerciseAnalysisResult:
    """
    Final result returned by the CV analysis pipeline.
    """

    exercise: str

    repetitions: list[RepetitionAnalysis] = field(
        default_factory=list
    )

    def to_dict(self) -> dict:
        return {
            "exercise": self.exercise,

            "total_repetitions": (
                len(self.repetitions)
            ),

            "repetitions": [
                repetition.to_dict()
                for repetition in self.repetitions
            ],
        }
