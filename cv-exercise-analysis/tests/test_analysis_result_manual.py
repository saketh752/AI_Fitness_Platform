from app.analysis.analysis_result import (
    ExerciseAnalysisResult,
    RepetitionAnalysis,
)


class FakeObject:
    def __init__(self, value):
        self.value = value

    def to_dict(self):
        return {"value": self.value}


def main():
    print("Testing final analysis result")
    print("=" * 60)

    repetition = RepetitionAnalysis(
        repetition_number=1,
        repetition=FakeObject("rep"),
        measurements=FakeObject("measurements"),
        form_analysis=FakeObject("form"),
    )

    result = ExerciseAnalysisResult(
        exercise="squat",
        repetitions=[repetition],
    )

    data = result.to_dict()

    print("\nFinal result")
    print("-" * 60)

    print(data)

    assert data["exercise"] == "squat"
    assert data["total_repetitions"] == 1
    assert len(data["repetitions"]) == 1

    rep = data["repetitions"][0]

    assert rep["repetition_number"] == 1
    assert rep["repetition"]["value"] == "rep"
    assert rep["measurements"]["value"] == "measurements"
    assert rep["form_analysis"]["value"] == "form"

    print("\nFinal analysis result test: PASSED")


if __name__ == "__main__":
    main()