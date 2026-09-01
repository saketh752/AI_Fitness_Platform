from dataclasses import dataclass

from app.analysis.bicep_measurements import (
    BicepMeasurements,
)


@dataclass
class BicepFormFinding:
    """
    Represents one bicep-curl form finding.
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
class BicepFormAnalysisResult:
    """
    Complete form analysis for one
    bicep-curl repetition.
    """

    repetition_number: int
    findings: list[BicepFormFinding]

    def to_dict(self) -> dict:
        return {
            "repetition_number": (
                self.repetition_number
            ),
            "findings": [
                finding.to_dict()
                for finding in self.findings
            ],
        }


class BicepFormAnalyzer:
    """
    Rule-based bicep-curl form analyzer.

    This layer interprets measurements.

    It does not perform:

        - pose detection
        - repetition detection
        - angle calculation
        - feedback generation
    """

    # --------------------------------------------------
    # MVP THRESHOLDS
    # --------------------------------------------------

    # Smaller angle means a more complete curl.
    FULL_CURL_THRESHOLD = 60.0

    # Larger angle means a more complete extension.
    FULL_EXTENSION_THRESHOLD = 160.0

    # Left/right elbow difference.
    ELBOW_ASYMMETRY_THRESHOLD = 10.0

    def __init__(
        self,
        full_curl_threshold: float = (
            FULL_CURL_THRESHOLD
        ),
        full_extension_threshold: float = (
            FULL_EXTENSION_THRESHOLD
        ),
        elbow_asymmetry_threshold: float = (
            ELBOW_ASYMMETRY_THRESHOLD
        ),
    ):
        self.full_curl_threshold = (
            full_curl_threshold
        )

        self.full_extension_threshold = (
            full_extension_threshold
        )

        self.elbow_asymmetry_threshold = (
            elbow_asymmetry_threshold
        )

    def analyze(
        self,
        measurements: BicepMeasurements,
    ) -> BicepFormAnalysisResult:
        """
        Analyze one completed bicep-curl repetition.
        """

        findings = []

        # --------------------------------------------------
        # CURL DEPTH
        # --------------------------------------------------

        if (
            measurements.average_bottom_elbow_angle
            <= self.full_curl_threshold
        ):

            findings.append(
                BicepFormFinding(
                    code="FULL_CURL",
                    severity="good",
                    message=(
                        "Good curl depth. "
                        "Keep maintaining this "
                        "range of motion."
                    ),
                )
            )

        else:

            findings.append(
                BicepFormFinding(
                    code="INCOMPLETE_CURL",
                    severity="warning",
                    message=(
                        "Curl the weight higher "
                        "and complete the full "
                        "range of motion."
                    ),
                )
            )

        # --------------------------------------------------
        # EXTENSION
        # --------------------------------------------------

        if (
            measurements.average_top_elbow_angle
            < self.full_extension_threshold
        ):

            findings.append(
                BicepFormFinding(
                    code="INCOMPLETE_EXTENSION",
                    severity="warning",
                    message=(
                        "Lower your arm further "
                        "before starting the next curl."
                    ),
                )
            )

        # --------------------------------------------------
        # ELBOW SYMMETRY
        # --------------------------------------------------

        if (
            measurements.elbow_symmetry
            > self.elbow_asymmetry_threshold
        ):

            findings.append(
                BicepFormFinding(
                    code="ELBOW_ASYMMETRY",
                    severity="warning",
                    message=(
                        "Your arms are moving unevenly. "
                        "Try to keep both sides balanced."
                    ),
                )
            )

        return BicepFormAnalysisResult(
            repetition_number=(
                measurements.repetition_number
            ),
            findings=findings,
        )