from dataclasses import dataclass, field
from typing import Any

from app.analysis.pushup_form_analysis import (
    PushupFormAnalyzer,
)
from app.analysis.pushup_measurement_calculator import (
    calculate_pushup_frame_measurements,
)
from app.analysis.pushup_measurements import (
    PushupMeasurements,
)
from app.analysis.pushup_phases import (
    PushupPhaseDetector,
)
from app.analysis.pushup_rep_detector import (
    PushupRepetitionDetector,
)
from app.feedback.generator import (
    FeedbackGenerator,
)


@dataclass
class PushupRepetitionAnalysis:
    """
    Complete analysis for one completed push-up repetition.
    """

    repetition_number: int
    repetition: Any
    measurements: PushupMeasurements
    form_analysis: Any
    feedback: list[Any] = field(
        default_factory=list
    )

    def to_dict(self) -> dict:
        return {
            "repetition_number": (
                self.repetition_number
            ),
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
class PushupAnalysisResult:
    """
    Final result returned by the push-up
    analysis pipeline.
    """

    exercise: str = "push_up"

    repetitions: list[
        PushupRepetitionAnalysis
    ] = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "exercise": self.exercise,
            "total_repetitions": len(
                self.repetitions
            ),
            "repetitions": [
                repetition.to_dict()
                for repetition in self.repetitions
            ],
        }


class PushupAnalysisPipeline:
    """
    Complete push-up analysis pipeline.

    Flow:

        landmarks
            ↓
        frame measurements
            ↓
        elbow angle
            ↓
        phase detection
            ↓
        repetition detection
            ↓
        repetition measurements
            ↓
        form analysis
            ↓
        feedback generation
            ↓
        completed repetition analysis
    """

    def __init__(
        self,
        phase_detector=None,
        repetition_detector=None,
        form_analyzer=None,
        feedback_generator=None,
    ):
        self.phase_detector = (
            phase_detector
            if phase_detector is not None
            else PushupPhaseDetector()
        )

        self.repetition_detector = (
            repetition_detector
            if repetition_detector is not None
            else PushupRepetitionDetector()
        )

        self.form_analyzer = (
            form_analyzer
            if form_analyzer is not None
            else PushupFormAnalyzer()
        )

        self.feedback_generator = (
            feedback_generator
            if feedback_generator is not None
            else FeedbackGenerator()
        )

        self.reset()

    def reset(self):
        """
        Reset the complete pipeline.
        """

        self.phase_detector.reset()
        self.repetition_detector.reset()

        self.frame_measurements = []
        self.completed_analyses = []

    def process_frame(
        self,
        landmarks,
        frame_index: int,
        timestamp_ms: int,
        direction: str,
    ):
        """
        Process one pose-landmark frame.

        Returns:
            PushupRepetitionAnalysis when a complete
            repetition is detected.

            None when the current frame does not
            complete a repetition.
        """

        # --------------------------------------------------
        # Calculate measurements for this frame
        # --------------------------------------------------

        measurements = (
            calculate_pushup_frame_measurements(
                landmarks
            )
        )

        self.frame_measurements.append(
            {
                "frame_index": frame_index,
                "timestamp_ms": timestamp_ms,
                "measurements": measurements,
            }
        )

        # --------------------------------------------------
        # Get average elbow angle
        # --------------------------------------------------

        elbow_angle = measurements[
            "average_elbow_angle"
        ]

        # --------------------------------------------------
        # Detect movement phase
        # --------------------------------------------------

        event = self.phase_detector.update(
            elbow_angle=elbow_angle,
            frame_index=frame_index,
            timestamp_ms=timestamp_ms,
            direction=direction,
        )

        # No phase transition
        if event is None:
            return None

        # --------------------------------------------------
        # Detect completed repetition
        # --------------------------------------------------

        repetition = (
            self.repetition_detector.update(
                event
            )
        )

        # No completed repetition yet
        if repetition is None:
            return None

        # --------------------------------------------------
        # Analyze completed repetition
        # --------------------------------------------------

        return self._analyze_repetition(
            repetition
        )

    def _get_measurements_for_repetition(
        self,
        repetition,
    ) -> list[dict]:
        """
        Get frame measurements belonging to
        one completed repetition.
        """

        return [
            item
            for item in self.frame_measurements
            if (
                repetition.start_frame
                <= item["frame_index"]
                <= repetition.end_frame
            )
        ]

    def _analyze_repetition(
        self,
        repetition,
    ) -> PushupRepetitionAnalysis:
        """
        Calculate final measurements, form analysis,
        and feedback for one completed repetition.
        """

        frames = (
            self._get_measurements_for_repetition(
                repetition
            )
        )

        # --------------------------------------------------
        # Collect elbow measurements
        # --------------------------------------------------

        bottom_angles = []
        top_angles = []

        for item in frames:
            measurement = item[
                "measurements"
            ]

            angle = measurement[
                "average_elbow_angle"
            ]

            if (
                item["frame_index"]
                == repetition.bottom_frame
            ):
                bottom_angles.append(angle)

            if (
                item["frame_index"]
                == repetition.start_frame
                or item["frame_index"]
                == repetition.end_frame
            ):
                top_angles.append(angle)

        # --------------------------------------------------
        # Fallback values
        # --------------------------------------------------

        if bottom_angles:
            average_bottom_elbow_angle = (
                sum(bottom_angles)
                / len(bottom_angles)
            )
        else:
            average_bottom_elbow_angle = (
                repetition.minimum_angle
            )

        if top_angles:
            average_top_elbow_angle = (
                sum(top_angles)
                / len(top_angles)
            )
        else:
            average_top_elbow_angle = 180.0

        # --------------------------------------------------
        # Body-line angle
        # --------------------------------------------------

        body_line_angles = [
            item["measurements"][
                "body_line_angle"
            ]
            for item in frames
        ]

        if body_line_angles:
            body_line_angle = (
                sum(body_line_angles)
                / len(body_line_angles)
            )
        else:
            body_line_angle = 180.0

        # --------------------------------------------------
        # Elbow symmetry
        # --------------------------------------------------

        symmetry_values = [
            item["measurements"][
                "elbow_symmetry"
            ]
            for item in frames
        ]

        if symmetry_values:
            elbow_symmetry = (
                sum(symmetry_values)
                / len(symmetry_values)
            )
        else:
            elbow_symmetry = 0.0

        # --------------------------------------------------
        # Create final measurement object
        # --------------------------------------------------

        measurement = PushupMeasurements(
            repetition_number=(
                repetition.repetition_number
            ),
            average_bottom_elbow_angle=(
                average_bottom_elbow_angle
            ),
            average_top_elbow_angle=(
                average_top_elbow_angle
            ),
            body_line_angle=body_line_angle,
            elbow_symmetry=elbow_symmetry,
            descent_duration_ms=(
                repetition.descent_duration_ms
            ),
            ascent_duration_ms=(
                repetition.ascent_duration_ms
            ),
            total_duration_ms=(
                repetition.total_duration_ms
            ),
        )

        # --------------------------------------------------
        # Form analysis
        # --------------------------------------------------

        form_analysis = (
            self.form_analyzer.analyze(
                measurement
            )
        )

        # --------------------------------------------------
        # Feedback generation
        # --------------------------------------------------

        feedback = (
            self.feedback_generator.generate(
                form_analysis
            )
        )

        # --------------------------------------------------
        # Complete repetition analysis
        # --------------------------------------------------

        analysis = PushupRepetitionAnalysis(
            repetition_number=(
                repetition.repetition_number
            ),
            repetition=repetition,
            measurements=measurement,
            form_analysis=form_analysis,
            feedback=feedback,
        )

        # --------------------------------------------------
        # Store completed analysis
        # --------------------------------------------------

        self.completed_analyses.append(
            analysis
        )

        return analysis

    def get_result(
        self,
    ) -> PushupAnalysisResult:
        """
        Return all completed push-up analyses,
        including measurements, form analysis,
        and feedback.
        """

        return PushupAnalysisResult(
            repetitions=list(
                self.completed_analyses
            )
        )


def analyze_pushup_video(
    video_path,
    model_path,
):
    """
    Analyze a push-up video.

    This function is the public entry point
    used by the API layer.
    """

    from app.preprocessing.video_processor import (
       VideoProcessor,
    )
    from app.pose.detector import (
        PoseDetector,
    )
    from app.pose.landmarks import (
        extract_landmarks,
    )

    pipeline = PushupAnalysisPipeline()

    with PoseDetector(
        model_path=str(model_path)
    ) as pose_detector:

        processor = VideoProcessor(
            video_path
        )

        previous_angle = None

        for (
            frame_index,
            timestamp_ms,
            frame,
        ) in processor.frames():

            results = pose_detector.detect(
                frame,
                timestamp_ms,
            )

            landmarks = extract_landmarks(
                results
            )

            if not landmarks:
                continue

            frame_measurements = (
                calculate_pushup_frame_measurements(
                    landmarks
                )
            )

            current_angle = (
                frame_measurements[
                    "average_elbow_angle"
                ]
            )

            if previous_angle is None:
                direction = "stable"

            elif (
                current_angle
                < previous_angle
            ):
                direction = "decreasing"

            elif (
                current_angle
                > previous_angle
            ):
                direction = "increasing"

            else:
                direction = "stable"

            pipeline.process_frame(
                landmarks=landmarks,
                frame_index=frame_index,
                timestamp_ms=timestamp_ms,
                direction=direction,
            )

            previous_angle = current_angle

    return pipeline.get_result()