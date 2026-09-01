from dataclasses import dataclass

from app.analysis.pushup_measurements import (
    PushupMeasurements,
)


@dataclass
class PushupFormFinding:
    """
    Represents one push-up form finding.
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
class PushupFormAnalysisResult:
    """
    Complete form analysis for one push-up repetition.
    """

    repetition_number: int
    findings: list[PushupFormFinding]

    def to_dict(self) -> dict:
        return {
            "repetition_number": self.repetition_number,
            "findings": [
                finding.to_dict()
                for finding in self.findings
            ],
        }


class PushupFormAnalyzer:
    """
    Rule-based push-up form analyzer.

    This layer interprets measurements.

    It does not perform:
        - pose detection
        - repetition detection
        - angle calculation
        - feedback generation
    """

    # --------------------------------------------------
    # MVP thresholds
    # --------------------------------------------------

    # Elbow angle at the bottom.
    #
    # A smaller angle means the user has lowered
    # themselves further toward the floor.
    #
    # 90 degrees is our MVP depth boundary.
    FULL_DEPTH_THRESHOLD = 90.0

    # At the top of the push-up the elbows should
    # return close to a straight position.
    TOP_ELBOW_THRESHOLD = 160.0

    # Difference between left and right elbow angles
    # above this value is considered asymmetry.
    ELBOW_ASYMMETRY_THRESHOLD = 40.0

    # Body-line deviation from a straight line.
    BODY_LINE_THRESHOLD = 45.0

    def __init__(
        self,
        full_depth_threshold: float = (
            FULL_DEPTH_THRESHOLD
        ),
        top_elbow_threshold: float = (
            TOP_ELBOW_THRESHOLD
        ),
        elbow_asymmetry_threshold: float = (
            ELBOW_ASYMMETRY_THRESHOLD
        ),
        body_line_threshold: float = (
            BODY_LINE_THRESHOLD
        ),
    ):
        self.full_depth_threshold = (
            full_depth_threshold
        )

        self.top_elbow_threshold = (
            top_elbow_threshold
        )

        self.elbow_asymmetry_threshold = (
            elbow_asymmetry_threshold
        )

        self.body_line_threshold = (
            body_line_threshold
        )

    def analyze(
        self,
        measurements: PushupMeasurements,
    ) -> PushupFormAnalysisResult:
        """
        Analyze one completed push-up repetition.
        """

        findings = []

        # --------------------------------------------------
        # DEPTH
        # --------------------------------------------------

        if (
            measurements.average_bottom_elbow_angle
            <= self.full_depth_threshold
        ):
            findings.append(
                PushupFormFinding(
                    code="FULL_DEPTH",
                    severity="good",
                    message=(
                        "Push-up depth is adequate."
                    ),
                )
            )

        else:
            findings.append(
                PushupFormFinding(
                    code="SHALLOW_PUSHUP",
                    severity="warning",
                    message=(
                        "Push-up depth is too shallow."
                    ),
                )
            )

        # --------------------------------------------------
        # TOP POSITION
        # --------------------------------------------------

        if (
            measurements.average_top_elbow_angle
            < self.top_elbow_threshold
        ):
            findings.append(
                PushupFormFinding(
                    code="INCOMPLETE_LOCKOUT",
                    severity="warning",
                    message=(
                        "Return closer to the top "
                        "position before starting "
                        "the next repetition."
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
                PushupFormFinding(
                    code="ELBOW_ASYMMETRY",
                    severity="warning",
                    message=(
                        "Your arms are moving unevenly. "
                        "Try to keep both sides balanced."
                    ),
                )
            )

        # --------------------------------------------------
        # BODY LINE
        # --------------------------------------------------

        body_line_deviation = abs(
            measurements.body_line_angle
            - 180.0
        )

        if (
            body_line_deviation
            > self.body_line_threshold
        ):
            findings.append(
                PushupFormFinding(
                    code="BODY_LINE",
                    severity="warning",
                    message=(
                        "Keep your body in a straighter "
                        "line throughout the push-up."
                    ),
                )
            )

        return PushupFormAnalysisResult(
            repetition_number=(
                measurements.repetition_number
            ),
            findings=findings,
        )