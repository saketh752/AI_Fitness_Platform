from app.analysis.smoothing import (
    MovingAverageSmoother,
)


def main():
    print("Testing movement signal smoothing")
    print("=" * 60)
    print()

    smoother = MovingAverageSmoother(
        window_size=3
    )

    values = [
        100.0,
        102.0,
        101.0,
        110.0,
        109.0,
    ]

    expected = [
        100.0,
        101.0,
        101.0,
        104.33,
        106.67,
    ]

    print("Input → Smoothed")
    print("-" * 60)

    for value, expected_value in zip(
        values,
        expected,
    ):
        smoothed = smoother.update(value)

        print(
            f"{value:7.2f} → "
            f"{smoothed:7.2f}"
        )

        assert abs(
            smoothed - expected_value
        ) < 0.01

    print()
    print(
        f"Window ready: {smoother.ready}"
    )

    assert smoother.ready is True

    smoother.reset()

    assert smoother.ready is False

    print(
        "Reset: PASSED"
    )

    # --------------------------------------------------
    # Invalid window protection
    # --------------------------------------------------

    try:
        MovingAverageSmoother(window_size=0)

        print(
            "Invalid window protection: FAILED"
        )
        return

    except ValueError:
        print(
            "Invalid window protection: PASSED"
        )

    print()
    print(
        "Smoothing test: PASSED"
    )


if __name__ == "__main__":
    main()