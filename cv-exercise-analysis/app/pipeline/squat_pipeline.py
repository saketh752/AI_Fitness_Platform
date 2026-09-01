from pathlib import Path

from app.preprocessing.video_processor import VideoProcessor
from app.pose.detector import PoseDetector
from app.pose.landmarks import extract_landmarks

from app.analysis.joint_angles import (
    calculate_squat_joint_angles,
)

from app.analysis.smoothing import (
    MovingAverageSmoother,
)

from app.analysis.phase_detection import (
    classify_direction,
)

from app.analysis.squat_phases import (
    SquatPhaseDetector,
)

from app.analysis.rep_detector import (
    SquatRepetitionDetector,
)

from app.analysis.squat_measurements import (
    calculate_squat_measurements,
)

from app.analysis.form_analysis import (
    SquatFormAnalyzer,
)

from app.analysis.analysis_result import (
    RepetitionAnalysis,
    ExerciseAnalysisResult,
)

from app.feedback.generator import (
    FeedbackGenerator,
)


class SquatAnalysisPipeline:
    """
    Complete independent squat-analysis pipeline.

    Pipeline:

        Video
          ↓
        Pose detection
          ↓
        Landmark extraction
          ↓
        Joint angles
          ↓
        Smoothing
          ↓
        Direction detection
          ↓
        Squat phase detection
          ↓
        Repetition detection
          ↓
        Squat measurements
          ↓
        Form analysis
          ↓
        Feedback generation
          ↓
        Final analysis result

    This class intentionally does not know anything about:

        - Flutter
        - backend
        - database
        - authentication
        - API
        - AR
        - AI/LLM

    It is an independent CV module.
    """

    def __init__(
        self,
        model_path: str | Path,
        smoothing_window: int = 5,
        direction_tolerance: float = 0.5,
        standing_threshold: float = 160.0,
        depth_threshold: float = 100.0,
        bottom_window_ms: int = 150,
    ):
        self.model_path = Path(model_path)

        if not self.model_path.exists():
            raise FileNotFoundError(
                f"Pose model not found: {self.model_path}"
            )

        self.smoothing_window = smoothing_window
        self.direction_tolerance = (
            direction_tolerance
        )
        self.standing_threshold = (
            standing_threshold
        )
        self.depth_threshold = depth_threshold
        self.bottom_window_ms = bottom_window_ms

    def _create_components(self):
        """
        Create fresh stateful analysis components.

        Each movement signal gets its own
        independent moving-average smoother.
        """

        return (
            MovingAverageSmoother(
                window_size=self.smoothing_window
            ),
            MovingAverageSmoother(
                window_size=self.smoothing_window
            ),
            MovingAverageSmoother(
                window_size=self.smoothing_window
            ),
            MovingAverageSmoother(
                window_size=self.smoothing_window
            ),
            SquatPhaseDetector(
                standing_threshold=(
                    self.standing_threshold
                ),
                depth_threshold=(
                    self.depth_threshold
                ),
            ),
            SquatRepetitionDetector(),
        )

    def _build_timeseries_row(
        self,
        frame_index: int,
        timestamp_ms: int,
        angles: dict[str, float],
        smoothed_left_knee: float,
        smoothed_right_knee: float,
        smoothed_left_hip: float,
        smoothed_right_hip: float,
    ) -> dict:
        """
        Build one internal time-series row.

        Raw measurements and their corresponding
        smoothed values are stored together.
        """

        return {
            "frame_index": frame_index,
            "timestamp_ms": timestamp_ms,

            "left_knee_2d": angles[
                "left_knee_2d"
            ],

            "right_knee_2d": angles[
                "right_knee_2d"
            ],

            "left_hip_2d": angles[
                "left_hip_2d"
            ],

            "right_hip_2d": angles[
                "right_hip_2d"
            ],

            "left_knee_3d": angles[
                "left_knee_3d"
            ],

            "right_knee_3d": angles[
                "right_knee_3d"
            ],

            "left_hip_3d": angles[
                "left_hip_3d"
            ],

            "right_hip_3d": angles[
                "right_hip_3d"
            ],

            "left_knee_2d_smoothed": (
                smoothed_left_knee
            ),

            "right_knee_2d_smoothed": (
                smoothed_right_knee
            ),

            "left_hip_2d_smoothed": (
                smoothed_left_hip
            ),

            "right_hip_2d_smoothed": (
                smoothed_right_hip
            ),
        }

    def _process_video(
        self,
        video_path: str | Path,
    ):
        """
        Process the video and produce:

            rows
            repetitions
        """

        video_path = Path(video_path)

        if not video_path.exists():
            raise FileNotFoundError(
                f"Video not found: {video_path}"
            )

        (
            left_knee_smoother,
            right_knee_smoother,
            left_hip_smoother,
            right_hip_smoother,
            phase_detector,
            rep_detector,
        ) = self._create_components()

        rows = []

        with VideoProcessor(video_path) as video:

            metadata = video.get_metadata()

            with PoseDetector(
                str(self.model_path)
            ) as detector:

                frame_index = 0

                while True:

                    frame = video.read_frame()

                    if frame is None:
                        break

                    timestamp_ms = int(
                        frame_index
                        * 1000
                        / metadata.fps
                    )

                    results = detector.detect(
                        frame,
                        timestamp_ms,
                    )

                    landmarks = extract_landmarks(
                        results
                    )

                    if not landmarks:
                        frame_index += 1
                        continue

                    angles = (
                        calculate_squat_joint_angles(
                            landmarks
                        )
                    )

                    # ----------------------------------
                    # Smooth squat signals
                    # ----------------------------------

                    smoothed_left_knee = (
                        left_knee_smoother.update(
                            angles["left_knee_2d"]
                        )
                    )

                    smoothed_right_knee = (
                        right_knee_smoother.update(
                            angles["right_knee_2d"]
                        )
                    )

                    smoothed_left_hip = (
                        left_hip_smoother.update(
                            angles["left_hip_2d"]
                        )
                    )

                    smoothed_right_hip = (
                        right_hip_smoother.update(
                            angles["right_hip_2d"]
                        )
                    )

                    # ----------------------------------
                    # Build measurement row
                    # ----------------------------------

                    row = self._build_timeseries_row(
                        frame_index=frame_index,
                        timestamp_ms=timestamp_ms,
                        angles=angles,
                        smoothed_left_knee=(
                            smoothed_left_knee
                        ),
                        smoothed_right_knee=(
                            smoothed_right_knee
                        ),
                        smoothed_left_hip=(
                            smoothed_left_hip
                        ),
                        smoothed_right_hip=(
                            smoothed_right_hip
                        ),
                    )

                    rows.append(row)

                    # ----------------------------------
                    # Movement direction
                    # ----------------------------------

                    if len(rows) == 1:

                        direction = "stable"

                    else:

                        previous_angle = float(
                            rows[-2][
                                "left_knee_2d_smoothed"
                            ]
                        )

                        direction = (
                            classify_direction(
                                previous_angle,
                                smoothed_left_knee,
                                tolerance=(
                                    self.direction_tolerance
                                ),
                            )
                        )

                    # ----------------------------------
                    # Squat phase detection
                    # ----------------------------------

                    phase_event = (
                        phase_detector.update(
                            angle=smoothed_left_knee,
                            frame_index=frame_index,
                            timestamp_ms=timestamp_ms,
                            direction=direction,
                        )
                    )

                    # ----------------------------------
                    # Repetition detection
                    # ----------------------------------

                    if phase_event:

                        rep_detector.update(
                            phase_event
                        )

                    frame_index += 1

        repetitions = (
            rep_detector.get_repetitions()
        )

        return rows, repetitions

    def analyze(
        self,
        video_path: str | Path,
    ) -> ExerciseAnalysisResult:
        """
        Analyze a complete squat video.

        Returns:
            ExerciseAnalysisResult
        """

        rows, repetitions = (
            self._process_video(
                video_path
            )
        )

        if not rows:
            raise ValueError(
                "No pose measurements were detected "
                "in the video."
            )

        form_analyzer = SquatFormAnalyzer()
        feedback_generator = FeedbackGenerator()

        repetition_analyses = []

        for repetition in repetitions:

            # ----------------------------------
            # Measurements
            # ----------------------------------

            measurements = (
                calculate_squat_measurements(
                    repetition=repetition,
                    rows=rows,
                    bottom_window_ms=(
                        self.bottom_window_ms
                    ),
                )
            )

            # ----------------------------------
            # Form analysis
            # ----------------------------------

            form_analysis = (
                form_analyzer.analyze(
                    measurements
                )
            )

            # ----------------------------------
            # User-facing feedback
            # ----------------------------------

            feedback = (
                feedback_generator.generate(
                    form_analysis
                )
            )

            # ----------------------------------
            # Combined repetition result
            # ----------------------------------

            repetition_analysis = (
                RepetitionAnalysis(
                    repetition_number=(
                        repetition.repetition_number
                    ),
                    repetition=repetition,
                    measurements=measurements,
                    form_analysis=form_analysis,
                    feedback=feedback,
                )
            )

            repetition_analyses.append(
                repetition_analysis
            )

        return ExerciseAnalysisResult(
            exercise="squat",
            repetitions=repetition_analyses,
        )


def analyze_squat_video(
    video_path: str | Path,
    model_path: str | Path,
) -> ExerciseAnalysisResult:
    """
    Convenience function for the complete squat
    analysis pipeline.

    Example:

        result = analyze_squat_video(
            video_path,
            model_path,
        )

        data = result.to_dict()
    """

    pipeline = SquatAnalysisPipeline(
        model_path=model_path
    )

    return pipeline.analyze(
        video_path
    )