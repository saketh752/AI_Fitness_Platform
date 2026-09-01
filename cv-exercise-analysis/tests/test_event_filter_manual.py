from app.analysis.phase_detection import (
    PhasePoint,
)

from app.analysis.event_filter import (
    filter_events,
)


def main():
    print("Testing movement event filtering")
    print("=" * 60)
    print()

    events = [
        # Initial event
        PhasePoint(
            frame_index=100,
            timestamp_ms=1666,
            value=175.0,
            phase="increasing_to_decreasing",
        ),

        # Too close → reject
        PhasePoint(
            frame_index=105,
            timestamp_ms=1751,
            value=174.0,
            phase="decreasing_to_increasing",
        ),

        # Far enough but value change too small → reject
        PhasePoint(
            frame_index=130,
            timestamp_ms=2168,
            value=168.0,
            phase="decreasing_to_increasing",
        ),

        # Far enough + large movement → accept
        PhasePoint(
            frame_index=160,
            timestamp_ms=2668,
            value=120.0,
            phase="decreasing_to_increasing",
        ),

        # Too close → reject
        PhasePoint(
            frame_index=165,
            timestamp_ms=2751,
            value=121.0,
            phase="increasing_to_decreasing",
        ),

        # Far enough + large movement → accept
        PhasePoint(
            frame_index=190,
            timestamp_ms=3168,
            value=175.0,
            phase="increasing_to_decreasing",
        ),
    ]

    filtered = filter_events(
        events,
        min_frames_between=15,
        min_value_change=10.0,
    )

    print("Filtered events")
    print("-" * 60)

    for event in filtered:
        print(
            f"Frame {event.frame_index}: "
            f"{event.value:.2f}° "
            f"{event.phase}"
        )

    assert len(filtered) == 3

    assert filtered[0].frame_index == 100
    assert filtered[1].frame_index == 160
    assert filtered[2].frame_index == 190

    print()
    print(
        "Minimum separation filtering: PASSED"
    )

    print(
        "Minimum amplitude filtering: PASSED"
    )

    # --------------------------------------------------
    # Empty input
    # --------------------------------------------------

    assert filter_events([]) == []

    print(
        "Empty input protection: PASSED"
    )

    print()
    print(
        "Event filtering test: PASSED"
    )


if __name__ == "__main__":
    main()