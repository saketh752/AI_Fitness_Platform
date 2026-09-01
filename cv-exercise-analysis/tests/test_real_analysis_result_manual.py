import csv
from pathlib import Path

from app.analysis.repetition import Repetition
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


BASE_DIR = Path(__file__).resolve().parents[1]

CSV_PATH = (
    BASE_DIR
    / "data"
    / "analysis"
    / "squat_timeseries_smoothed.csv"
)


# --------------------------------------------------
# Validated repetitions from the real squat video
# --------------------------------------------------

REPETITIONS = [
    (33, 256, 334),
    (377, 410, 480),
    (533, 546, 619),
    (668, 681, 757),
    (798, 811, 885),
    (1014, 1115, 1165),
    (1209, 1232, 1268),
]


def load_rows(path: Path) -> list[dict]:
    with path.open(
        "r",
        newline="",
        encoding="utf-8",
    ) as file:
        return list(csv.DictReader(file))


def build_repetition(
    rows: list[dict],
    repetition_number: int,
    start_frame: int,
    bottom_frame: int,
    end_frame: int,
) -> Repetition:

    start_row = rows[start_frame]
    bottom_row = rows[bottom_frame]
    end_row = rows[end_frame]

    start_timestamp = int(
        start_row["timestamp_ms"]
    )

    bottom_timestamp = int(
        bottom_row["timestamp_ms"]
    )

    end_timestamp = int(
        end_row["timestamp_ms"]
    )

    return Repetition(
        repetition_number=repetition_number,

        start_frame=start_frame,
        bottom_frame=bottom_frame,
        end_frame=end_frame,

        start_timestamp_ms=start_timestamp,
        bottom_timestamp_ms=bottom_timestamp,
        end_timestamp_ms=end_timestamp,

        minimum_angle=float(
            bottom_row["left_knee_2d_smoothed"]
        ),

        descent_duration_ms=(
            bottom_timestamp
            - start_timestamp
        ),

        ascent_duration_ms=(
            end_timestamp
            - bottom_timestamp
        ),

        total_duration_ms=(
            end_timestamp
            - start_timestamp
        ),
    )


def build_analysis(
    rows: list[dict],
    repetition: Repetition,
    analyzer: SquatFormAnalyzer,
) -> RepetitionAnalysis:

    measurements = calculate_squat_measurements(
        repetition=repetition,
        rows=rows,
        bottom_window_ms=150,
    )

    form_analysis = analyzer.analyze(
        measurements
    )

    return RepetitionAnalysis(
        repetition_number=(
            repetition.repetition_number
        ),
        repetition=repetition,
        measurements=measurements,
        form_analysis=form_analysis,
    )


def validate_result(
    result: ExerciseAnalysisResult,
):
    """
    Validate the complete nested analysis result.
    """

    data = result.to_dict()

    # --------------------------------------------------
    # Top-level structure
    # --------------------------------------------------

    assert data["exercise"] == "squat"

    assert (
        data["total_repetitions"] == 7
    )

    assert (
        len(data["repetitions"]) == 7
    )

    # --------------------------------------------------
    # Repetition structure
    # --------------------------------------------------

    for index, item in enumerate(
        data["repetitions"],
        start=1,
    ):

        assert (
            item["repetition_number"]
            == index
        )

        assert "repetition" in item
        assert "measurements" in item
        assert "form_analysis" in item

        repetition = item["repetition"]

        assert (
            repetition["start_frame"]
            < repetition["bottom_frame"]
            < repetition["end_frame"]
        )

        assert (
            repetition["start_timestamp_ms"]
            < repetition["bottom_timestamp_ms"]
            < repetition["end_timestamp_ms"]
        )

        assert (
            repetition["total_duration_ms"]
            > 0
        )

    # --------------------------------------------------
    # Measurement structure
    # --------------------------------------------------

    for item in data["repetitions"]:

        measurements = item["measurements"]

        assert (
            measurements["repetition_number"]
            == item["repetition_number"]
        )

        assert "knee" in measurements
        assert "hip" in measurements
        assert "knee_3d" in measurements
        assert "hip_3d" in measurements
        assert "timing" in measurements
        assert "bottom_window" in measurements

        knee = measurements["knee"]

        assert "bottom_left_angle" in knee
        assert "bottom_right_angle" in knee
        assert "average_bottom_angle" in knee
        assert "asymmetry" in knee

        hip = measurements["hip"]

        assert "bottom_left_angle" in hip
        assert "bottom_right_angle" in hip
        assert "average_bottom_angle" in hip
        assert "asymmetry" in hip

        timing = measurements["timing"]

        assert (
            timing["descent_duration_ms"]
            >= 0
        )

        assert (
            timing["ascent_duration_ms"]
            >= 0
        )

        assert (
            timing["total_duration_ms"]
            > 0
        )

        bottom_window = (
            measurements["bottom_window"]
        )

        assert (
            bottom_window["sample_count"]
            > 0
        )

    # --------------------------------------------------
    # Form-analysis structure
    # --------------------------------------------------

    for index, item in enumerate(
        data["repetitions"],
        start=1,
    ):

        form = item["form_analysis"]

        assert (
            form["repetition_number"]
            == index
        )

        assert "findings" in form

        assert isinstance(
            form["findings"],
            list,
        )

        assert len(
            form["findings"]
        ) > 0

        for finding in form["findings"]:

            assert finding["code"]
            assert finding["severity"]
            assert finding["message"]


def print_result(
    data: dict,
):
    print()
    print("Final analysis")
    print("-" * 70)

    print(
        f"Exercise: {data['exercise']}"
    )

    print(
        f"Total repetitions: "
        f"{data['total_repetitions']}"
    )

    print()

    for item in data["repetitions"]:

        number = item[
            "repetition_number"
        ]

        measurements = item[
            "measurements"
        ]

        form = item[
            "form_analysis"
        ]

        knee = measurements[
            "knee"
        ]

        print(
            f"Rep {number}"
        )

        print(
            "  Average bottom knee: "
            f"{knee['average_bottom_angle']:.2f}°"
        )

        print(
            "  Knee asymmetry: "
            f"{knee['asymmetry']:.2f}°"
        )

        print(
            "  Hip asymmetry: "
            f"{measurements['hip']['asymmetry']:.2f}°"
        )

        print("  Findings:")

        for finding in form[
            "findings"
        ]:

            print(
                f"    {finding['code']}: "
                f"{finding['severity']} - "
                f"{finding['message']}"
            )

        print()


def main():

    print(
        "Testing final analysis "
        "with real squat data"
    )

    print("=" * 70)

    # --------------------------------------------------
    # Load real time series
    # --------------------------------------------------

    assert CSV_PATH.exists(), (
        f"CSV not found: {CSV_PATH}"
    )

    rows = load_rows(
        CSV_PATH
    )

    print()
    print(
        f"Rows loaded: {len(rows)}"
    )

    assert len(rows) == 1299

    # --------------------------------------------------
    # Create form analyzer
    # --------------------------------------------------

    analyzer = SquatFormAnalyzer()

    # --------------------------------------------------
    # Build complete repetition analyses
    # --------------------------------------------------

    analyses = []

    for number, boundaries in enumerate(
        REPETITIONS,
        start=1,
    ):

        start_frame, bottom_frame, end_frame = (
            boundaries
        )

        repetition = build_repetition(
            rows=rows,
            repetition_number=number,
            start_frame=start_frame,
            bottom_frame=bottom_frame,
            end_frame=end_frame,
        )

        analysis = build_analysis(
            rows=rows,
            repetition=repetition,
            analyzer=analyzer,
        )

        analyses.append(
            analysis
        )

    # --------------------------------------------------
    # Build final exercise result
    # --------------------------------------------------

    result = ExerciseAnalysisResult(
        exercise="squat",
        repetitions=analyses,
    )

    # --------------------------------------------------
    # Convert to dictionary
    # --------------------------------------------------

    data = result.to_dict()

    # --------------------------------------------------
    # Print final result
    # --------------------------------------------------

    print_result(
        data
    )

    # --------------------------------------------------
    # Validate
    # --------------------------------------------------

    print(
        "Validation"
    )

    print("-" * 70)

    validate_result(
        result
    )

    print(
        "7 repetitions analyzed: PASSED"
    )

    print(
        "Repetition structure: PASSED"
    )

    print(
        "Measurement structure: PASSED"
    )

    print(
        "Form-analysis structure: PASSED"
    )

    print(
        "Nested dictionary conversion: PASSED"
    )

    print()
    print(
        "Final real analysis result: PASSED"
    )


if __name__ == "__main__":
    main()