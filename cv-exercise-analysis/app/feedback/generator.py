from dataclasses import dataclass

from app.analysis.form_analysis import (
    FormAnalysisResult,
    FormFinding,
)


@dataclass
class FeedbackItem:
    """
    User-facing coaching feedback generated from
    a structured form-analysis finding.
    """

    repetition_number: int
    code: str
    severity: str
    message: str

    def to_dict(self) -> dict:
        return {
            "repetition_number": self.repetition_number,
            "code": self.code,
            "severity": self.severity,
            "message": self.message,
        }


class FeedbackGenerator:
    """
    Converts deterministic CV findings into
    user-friendly coaching feedback.

    The CV analysis decides WHAT is wrong.
    This layer decides HOW to communicate it.
    """

    MESSAGES = {
        "FULL_DEPTH": (
            "Good depth. Keep maintaining this range of motion."
        ),

        "SHALLOW_SQUAT": (
            "Half rep — squat depth needs improvement. "
            "Try lowering your body further before standing up."
        ),

        "KNEE_ASYMMETRY": (
            "Your knee angles are uneven. "
            "Try to keep both sides moving more evenly."
        ),

        "HIP_ASYMMETRY": (
            "Your hip angles are uneven. "
            "Try to keep your hips level and your movement balanced."
        ),
    }

    def generate(
        self,
        analysis: FormAnalysisResult,
    ) -> list[FeedbackItem]:
        """
        Generate coaching feedback for one repetition.
        """

        feedback = []

        for finding in analysis.findings:

            message = self.MESSAGES.get(
                finding.code,
                finding.message,
            )

            feedback.append(
                FeedbackItem(
                    repetition_number=(
                        analysis.repetition_number
                    ),
                    code=finding.code,
                    severity=finding.severity,
                    message=message,
                )
            )

        return feedback

    def generate_from_finding(
        self,
        repetition_number: int,
        finding: FormFinding,
    ) -> FeedbackItem:
        """
        Generate one feedback item from one finding.
        """

        message = self.MESSAGES.get(
            finding.code,
            finding.message,
        )

        return FeedbackItem(
            repetition_number=repetition_number,
            code=finding.code,
            severity=finding.severity,
            message=message,
        )
