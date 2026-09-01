from dataclasses import dataclass

from app.analysis.squat_measurements import (
    SquatMeasurements,
)


@dataclass
class FormFinding:
    """
    Represents one form-analysis finding.
    """

    code: str
    severity: str
    message: str

    def to_dict(self) -> dict:
        return {
            "code": self.code,
            "severity": self.severity,
            "message": self.message,
        }


@dataclass
class FormAnalysisResult:
    """
    Complete form analysis for one repetition.
    """

    repetition_number: int
    findings: list[FormFinding]

    def to_dict(self) -> dict:
        return {
            "repetition_number": self.repetition_number,
            "findings": [
                finding.to_dict()
                for finding in self.findings
            ],
        }


class SquatFormAnalyzer:
    """
    Simple rule-based squat form analyzer.

    This layer interprets measurements.
    It does not perform pose detection,
    repetition detection, or measurement.
    """

    # --------------------------------------------------
    # MVP thresholds
    # --------------------------------------------------

    # A squat with an average bottom knee angle
    # of 90 degrees or less is considered full depth.
    FULL_DEPTH_THRESHOLD = 90.0

    # Left/right knee difference above this value
    # is considered meaningful asymmetry.
    KNEE_ASYMMETRY_THRESHOLD = 10.0

    # Left/right hip difference above this value
    # is considered meaningful asymmetry.
    HIP_ASYMMETRY_THRESHOLD = 15.0

    def __init__(
        self,
        full_depth_threshold: float = (
            FULL_DEPTH_THRESHOLD
        ),
        knee_asymmetry_threshold: float = (
            KNEE_ASYMMETRY_THRESHOLD
        ),
        hip_asymmetry_threshold: float = (
            HIP_ASYMMETRY_THRESHOLD
        ),
    ):
        self.full_depth_threshold = (
            full_depth_threshold
        )

        self.knee_asymmetry_threshold = (
            knee_asymmetry_threshold
        )

        self.hip_asymmetry_threshold = (
            hip_asymmetry_threshold
        )

    def analyze(
        self,
        measurements: SquatMeasurements,
    ) -> FormAnalysisResult:
        """
        Analyze one completed squat repetition.
        """

        findings = []

        # --------------------------------------------------
        # Depth
        # --------------------------------------------------

        if (
            measurements.average_bottom_knee_angle
            <= self.full_depth_threshold
        ):
            findings.append(
                FormFinding(
                    code="FULL_DEPTH",
                    severity="good",
                    message="Squat depth is adequate.",
                )
            )
        else:
            findings.append(
                FormFinding(
                    code="SHALLOW_SQUAT",
                    severity="warning",
                    message=(
                        "Squat depth is too shallow."
                    ),
                )
            )

        # --------------------------------------------------
        # Knee asymmetry
        # --------------------------------------------------

        if (
            measurements.knee_angle_asymmetry
            > self.knee_asymmetry_threshold
        ):
            findings.append(
                FormFinding(
                    code="KNEE_ASYMMETRY",
                    severity="warning",
                    message=(
                        "Noticeable knee angle "
                        "asymmetry detected."
                    ),
                )
            )

        # --------------------------------------------------
        # Hip asymmetry
        # --------------------------------------------------

        if (
            measurements.hip_angle_asymmetry
            > self.hip_asymmetry_threshold
        ):
            findings.append(
                FormFinding(
                    code="HIP_ASYMMETRY",
                    severity="warning",
                    message=(
                        "Noticeable hip angle "
                        "asymmetry detected."
                    ),
                )
            )

        return FormAnalysisResult(
            repetition_number=(
                measurements.repetition_number
            ),
            findings=findings,
        )