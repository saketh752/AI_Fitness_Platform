from dataclasses import dataclass

from app.analysis.bicep_form_analysis import (
    BicepFormAnalysisResult,
)


@dataclass
class BicepCurlFeedbackItem:
    """
    User-facing feedback generated from
    bicep-curl form analysis.
    """

    severity: str
    message: str

    def to_dict(self) -> dict:
        return {
            "severity": self.severity,
            "message": self.message,
        }


class BicepCurlFeedbackGenerator:
    """
    Converts bicep-curl form findings into
    user-facing feedback.

    This layer does not perform:
        - pose detection
        - angle calculation
        - repetition detection
        - form analysis
    """

    def generate(
        self,
        analysis: BicepFormAnalysisResult,
    ) -> list[BicepCurlFeedbackItem]:
        """
        Generate feedback for one completed
        bicep-curl repetition.
        """

        feedback = []

        for finding in analysis.findings:
            feedback.append(
                BicepCurlFeedbackItem(
                    severity=finding.severity,
                    message=finding.message,
                )
            )

        return feedback

    def generate_dicts(
        self,
        analysis: BicepFormAnalysisResult,
    ) -> list[dict]:
        """
        Generate JSON-compatible feedback.
        """

        return [
            item.to_dict()
            for item in self.generate(analysis)
        ]