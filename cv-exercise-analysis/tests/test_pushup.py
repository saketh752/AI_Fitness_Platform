from app.analysis.pushup_phases import (
    PushupPhaseDetector,
)

from app.analysis.pushup_rep_detector import (
    PushupRepetitionDetector,
)


def test_pushup_repetition_detection():

    phase_detector = PushupPhaseDetector()
    rep_detector = PushupRepetitionDetector()

    sequence = [
        # angle, frame, timestamp, direction
        (170.0, 0, 0, "increasing"),
        (150.0, 10, 333, "decreasing"),
        (120.0, 20, 666, "decreasing"),
        (95.0, 30, 999, "decreasing"),
        (110.0, 40, 1332, "increasing"),
        (140.0, 50, 1665, "increasing"),
        (165.0, 60, 1998, "increasing"),
    ]

    for angle, frame, timestamp, direction in sequence:

        event = phase_detector.update(
            elbow_angle=angle,
            frame_index=frame,
            timestamp_ms=timestamp,
            direction=direction,
        )

        if event is not None:
            rep_detector.update(event)

    repetitions = rep_detector.get_repetitions()

    assert len(repetitions) == 1

    rep = repetitions[0]

    assert rep.repetition_number == 1

    assert (
        rep.start_frame
        < rep.bottom_frame
        < rep.end_frame
    )

    assert (
        rep.start_timestamp_ms
        < rep.bottom_timestamp_ms
        < rep.end_timestamp_ms
    )

    assert rep.minimum_angle == 95.0

    # 999 - 333
    assert rep.descent_duration_ms == 666

    # 1998 - 999
    assert rep.ascent_duration_ms == 999

    # 1998 - 333
    assert rep.total_duration_ms == 1665