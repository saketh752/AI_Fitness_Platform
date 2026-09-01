import csv
from pathlib import Path

from app.analysis.repetition import Repetition
from app.analysis.squat_measurements import (
    calculate_squat_measurements,
)
from app.analysis.form_analysis import (
    SquatFormAnalyzer,
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


def main():
    print(
        "Testing squat form analysis on real video"
    )
    print("=" * 70)

    # --------------------------------------------------
    # Load real time series
    # --------------------------------------------------

    rows = load_rows(CSV_PATH)

    print()
    print(
        f"Rows loaded: {len(rows)}"
    )

    assert len(rows) == 1299

    # --------------------------------------------------
    # Create analyzer
    # --------------------------------------------------

    analyzer = SquatFormAnalyzer()

    all_results = []

    # --------------------------------------------------
    # Analyze all seven repetitions
    # --------------------------------------------------

    print()
    print("Repetition form analysis")
    print("-" * 70)

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

        measurements = calculate_squat_measurements(
            repetition=repetition,
            rows=rows,
            bottom_window_ms=150,
        )

        result = analyzer.analyze(
            measurements
        )

        all_results.append(result)

        print()
        print(
            f"Rep {number}"
        )

        print(
            f"  Bottom knee: "
            f"{measurements.average_bottom_knee_angle:.2f}°"
        )

        print(
            f"  Knee asymmetry: "
            f"{measurements.knee_angle_asymmetry:.2f}°"
        )

        print(
            f"  Hip asymmetry: "
            f"{measurements.hip_angle_asymmetry:.2f}°"
        )

        print("  Findings:")

        for finding in result.findings:
            print(
                f"    {finding.code}: "
                f"{finding.severity}"
            )

    # --------------------------------------------------
    # Validate results
    # --------------------------------------------------

    print()
    print("Validation")
    print("-" * 70)

    assert len(all_results) == 7

    for index, result in enumerate(
        all_results,
        start=1,
    ):
        assert (
            result.repetition_number == index
        )

        assert len(result.findings) > 0

        for finding in result.findings:
            assert finding.code
            assert finding.severity
            assert finding.message

    print(
        "7 repetitions analyzed: PASSED"
    )

    print(
        "Finding validation: PASSED"
    )

    # --------------------------------------------------
    # Dictionary conversion
    # --------------------------------------------------

    dictionaries = [
        result.to_dict()
        for result in all_results
    ]

    assert len(dictionaries) == 7

    for item in dictionaries:
        assert "repetition_number" in item
        assert "findings" in item
        assert isinstance(
            item["findings"],
            list,
        )

    print(
        "Dictionary conversion: PASSED"
    )

    print()
    print(
        "Real squat form analysis: PASSED"
    )


if __name__ == "__main__":
    main()