from app.analysis.squat_measurements import SquatMeasurements
from app.analysis.form_analysis import SquatFormAnalyzer


def create_measurements(
    knee_angle: float,
    knee_asymmetry: float,
    hip_asymmetry: float,
) -> SquatMeasurements:
    return SquatMeasurements(
        repetition_number=1,

        bottom_left_knee_angle=knee_angle,
        bottom_right_knee_angle=knee_angle,
        average_bottom_knee_angle=knee_angle,
        knee_angle_asymmetry=knee_asymmetry,

        bottom_left_hip_angle=85.0,
        bottom_right_hip_angle=85.0,
        average_bottom_hip_angle=85.0,
        hip_angle_asymmetry=hip_asymmetry,

        bottom_left_knee_angle_3d=110.0,
        bottom_right_knee_angle_3d=110.0,

        bottom_left_hip_angle_3d=105.0,
        bottom_right_hip_angle_3d=105.0,

        descent_duration_ms=1000,
        ascent_duration_ms=1000,
        total_duration_ms=2000,

        bottom_window_start_ms=4000,
        bottom_window_end_ms=4300,
        bottom_sample_count=18,
    )


def get_codes(result):
    return [
        finding.code
        for finding in result.findings
    ]


def main():
    print("Testing squat form analysis")
    print("=" * 60)

    analyzer = SquatFormAnalyzer()

    # --------------------------------------------------
    # Good squat
    # --------------------------------------------------

    print()
    print("Case 1: Good squat")
    print("-" * 60)

    measurements = create_measurements(
        knee_angle=88.0,
        knee_asymmetry=5.0,
        hip_asymmetry=10.0,
    )

    result = analyzer.analyze(measurements)

    codes = get_codes(result)

    print("Findings:")

    for finding in result.findings:
        print(
            f"  {finding.code}: "
            f"{finding.severity} - "
            f"{finding.message}"
        )

    assert "FULL_DEPTH" in codes
    assert "SHALLOW_SQUAT" not in codes
    assert "KNEE_ASYMMETRY" not in codes
    assert "HIP_ASYMMETRY" not in codes

    print("Good squat validation: PASSED")

    # --------------------------------------------------
    # Shallow squat
    # --------------------------------------------------

    print()
    print("Case 2: Shallow squat")
    print("-" * 60)

    measurements = create_measurements(
        knee_angle=115.0,
        knee_asymmetry=5.0,
        hip_asymmetry=10.0,
    )

    result = analyzer.analyze(measurements)

    codes = get_codes(result)

    print("Findings:")

    for finding in result.findings:
        print(
            f"  {finding.code}: "
            f"{finding.severity} - "
            f"{finding.message}"
        )

    assert "SHALLOW_SQUAT" in codes
    assert "FULL_DEPTH" not in codes

    print("Shallow squat validation: PASSED")

    # --------------------------------------------------
    # Knee asymmetry
    # --------------------------------------------------

    print()
    print("Case 3: Knee asymmetry")
    print("-" * 60)

    measurements = create_measurements(
        knee_angle=88.0,
        knee_asymmetry=15.0,
        hip_asymmetry=10.0,
    )

    result = analyzer.analyze(measurements)

    codes = get_codes(result)

    print("Findings:")

    for finding in result.findings:
        print(
            f"  {finding.code}: "
            f"{finding.severity} - "
            f"{finding.message}"
        )

    assert "FULL_DEPTH" in codes
    assert "KNEE_ASYMMETRY" in codes
    assert "SHALLOW_SQUAT" not in codes

    print("Knee asymmetry validation: PASSED")

    # --------------------------------------------------
    # Hip asymmetry
    # --------------------------------------------------

    print()
    print("Case 4: Hip asymmetry")
    print("-" * 60)

    measurements = create_measurements(
        knee_angle=88.0,
        knee_asymmetry=5.0,
        hip_asymmetry=20.0,
    )

    result = analyzer.analyze(measurements)

    codes = get_codes(result)

    print("Findings:")

    for finding in result.findings:
        print(
            f"  {finding.code}: "
            f"{finding.severity} - "
            f"{finding.message}"
        )

    assert "FULL_DEPTH" in codes
    assert "HIP_ASYMMETRY" in codes
    assert "SHALLOW_SQUAT" not in codes

    print("Hip asymmetry validation: PASSED")

    # --------------------------------------------------
    # Multiple findings
    # --------------------------------------------------

    print()
    print("Case 5: Multiple form issues")
    print("-" * 60)

    measurements = create_measurements(
        knee_angle=115.0,
        knee_asymmetry=20.0,
        hip_asymmetry=25.0,
    )

    result = analyzer.analyze(measurements)

    codes = get_codes(result)

    print("Findings:")

    for finding in result.findings:
        print(
            f"  {finding.code}: "
            f"{finding.severity} - "
            f"{finding.message}"
        )

    assert "SHALLOW_SQUAT" in codes
    assert "KNEE_ASYMMETRY" in codes
    assert "HIP_ASYMMETRY" in codes

    print("Multiple findings validation: PASSED")

    # --------------------------------------------------
    # Dictionary conversion
    # --------------------------------------------------

    print()
    print("Dictionary conversion")
    print("-" * 60)

    result_dict = result.to_dict()

    assert isinstance(result_dict, dict)
    assert result_dict["repetition_number"] == 1
    assert "findings" in result_dict
    assert isinstance(
        result_dict["findings"],
        list,
    )

    for finding in result_dict["findings"]:
        assert "code" in finding
        assert "severity" in finding
        assert "message" in finding

    print("Dictionary conversion: PASSED")

    print()
    print("Form analysis test: PASSED")


if __name__ == "__main__":
    main()