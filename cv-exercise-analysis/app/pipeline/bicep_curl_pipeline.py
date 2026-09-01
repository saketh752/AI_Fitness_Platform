from dataclasses import dataclass
from typing import Any


from app.analysis.bicep_curl_angles import (
    calculate_bicep_curl_frame_measurements,
)

from app.analysis.bicep_phases import (
    BicepPhaseDetector,
)

from app.analysis.bicep_rep_detector import (
    BicepRepetitionDetector,
)

from app.analysis.bicep_measurements import (
    BicepMeasurements,
)

from app.analysis.bicep_form_analysis import (
    BicepFormAnalyzer,
)

from app.feedback.bicep_curl_feedback import (
    BicepCurlFeedbackGenerator,
)


@dataclass
class BicepCurlRepetitionAnalysis:
    """
    Complete analysis for one bicep-curl repetition.
    """

    measurements: BicepMeasurements
    form_analysis: Any
    feedback: list

    def to_dict(self) -> dict:
        return {
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
class BicepCurlAnalysisResult:
    """
    Final bicep-curl video analysis result.
    """

    repetitions: list[
        BicepCurlRepetitionAnalysis
    ]

    def to_dict(self) -> dict:
        return {
            "repetitions": [
                repetition.to_dict()
                for repetition in self.repetitions
            ],

            "total_repetitions": len(
                self.repetitions
            ),
        }


class BicepCurlAnalysisPipeline:
    """
    Coordinates the complete bicep-curl analysis flow.

    Pipeline:

        landmarks
            ↓
        angle measurements
            ↓
        phase detection
            ↓
        repetition detection
            ↓
        repetition measurements
            ↓
        form analysis
            ↓
        feedback
    """

    def __init__(self):

        self.phase_detector = (
            BicepPhaseDetector()
        )

        self.repetition_detector = (
            BicepRepetitionDetector()
        )

        self.form_analyzer = (
            BicepFormAnalyzer()
        )

        self.feedback_generator = (
            BicepCurlFeedbackGenerator()
        )

        self.completed_analyses = []

    def process_frame(
        self,
        landmarks,
        frame_index: int,
        timestamp_ms: int,
        direction: str,
    ):
        """
        Process one pose frame.

        Returns a completed repetition analysis
        only when a repetition is completed.
        """

        # --------------------------------------------------
        # FRAME MEASUREMENTS
        # --------------------------------------------------

        measurements = (
            calculate_bicep_curl_frame_measurements(
                landmarks
            )
        )

        elbow_angle = (
            measurements[
                "average_elbow_angle"
            ]
        )

        # --------------------------------------------------
        # PHASE DETECTION
        # --------------------------------------------------

        phase_event = (
            self.phase_detector.update(
                elbow_angle=elbow_angle,
                frame_index=frame_index,
                timestamp_ms=timestamp_ms,
                direction=direction,
            )
        )

        if phase_event is None:
            return None

        # --------------------------------------------------
        # REPETITION DETECTION
        # --------------------------------------------------

        repetition = (
            self.repetition_detector.update(
                phase_event
            )
        )

        if repetition is None:
            return None

        # --------------------------------------------------
        # REPETITION MEASUREMENTS
        # --------------------------------------------------

        repetition_measurements = (
            BicepMeasurements(
                repetition_number=(
                    repetition.repetition_number
                ),

                average_bottom_elbow_angle=(
                    repetition.minimum_angle
                ),

                # The top event is the phase event
                # that completed the repetition.
                average_top_elbow_angle=(
                    phase_event.elbow_angle
                ),

                elbow_symmetry=(
                    measurements[
                        "elbow_symmetry"
                    ]
                ),

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
        )

        # --------------------------------------------------
        # FORM ANALYSIS
        # --------------------------------------------------

        form_analysis = (
            self.form_analyzer.analyze(
                repetition_measurements
            )
        )

        # --------------------------------------------------
        # FEEDBACK
        # --------------------------------------------------

        feedback = (
            self.feedback_generator.generate(
                form_analysis
            )
        )

        # --------------------------------------------------
        # COMPLETE RESULT
        # --------------------------------------------------

        result = (
            BicepCurlRepetitionAnalysis(
                measurements=(
                    repetition_measurements
                ),
                form_analysis=form_analysis,
                feedback=feedback,
            )
        )

        self.completed_analyses.append(
            result
        )

        return result

    def get_result(
        self,
    ) -> BicepCurlAnalysisResult:
        """
        Return all completed bicep-curl analyses.
        """

        return BicepCurlAnalysisResult(
            repetitions=list(
                self.completed_analyses
            )
        )


def analyze_bicep_curl_video(
    video_path,
    model_path,
):
    """
    Analyze a complete bicep-curl video.

    Public entry point used by the API layer.
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

    pipeline = (
        BicepCurlAnalysisPipeline()
    )

    previous_angle = None

    with PoseDetector(
        model_path=str(model_path)
    ) as pose_detector:

        processor = VideoProcessor(
            video_path
        )

        try:

            for (
                frame_index,
                timestamp_ms,
                frame,
            ) in processor.frames():

                # --------------------------------------------------
                # POSE DETECTION
                # --------------------------------------------------

                results = (
                    pose_detector.detect(
                        frame,
                        timestamp_ms,
                    )
                )

                landmarks = (
                    extract_landmarks(
                        results
                    )
                )

                if not landmarks:
                    continue

                # --------------------------------------------------
                # CURRENT ANGLE
                # --------------------------------------------------

                frame_measurements = (
                    calculate_bicep_curl_frame_measurements(
                        landmarks
                    )
                )

                current_angle = (
                    frame_measurements[
                        "average_elbow_angle"
                    ]
                )

                # --------------------------------------------------
                # MOVEMENT DIRECTION
                # --------------------------------------------------

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

                # --------------------------------------------------
                # PIPELINE
                # --------------------------------------------------

                pipeline.process_frame(
                    landmarks=landmarks,
                    frame_index=frame_index,
                    timestamp_ms=timestamp_ms,
                    direction=direction,
                )

                previous_angle = (
                    current_angle
                )

        finally:

            processor.release()

    return pipeline.get_result()