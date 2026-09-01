from pathlib import Path

from app.pipeline.squat_pipeline import analyze_squat_video


SUPPORTED_VIDEO_EXTENSIONS = {
    ".mp4",
    ".mov",
    ".avi",
    ".mkv",
}


def analyze_squat(
    video_path: str | Path,
    model_path: str | Path,
) -> dict:
    """
    Run the complete squat CV analysis pipeline.

    This is the public CV entry point.

    It intentionally has no dependency on:
        - Flutter
        - MySQL
        - the main application backend
        - external API services
    """

    video_path = Path(video_path)
    model_path = Path(model_path)

    # --------------------------------------------------
    # Validate video
    # --------------------------------------------------

    if not video_path.exists():
        raise FileNotFoundError(
            f"Video file not found: {video_path}"
        )

    if not video_path.is_file():
        raise ValueError(
            f"Video path is not a file: {video_path}"
        )

    if video_path.suffix.lower() not in SUPPORTED_VIDEO_EXTENSIONS:
        raise ValueError(
            "Unsupported video format: "
            f"{video_path.suffix}"
        )

    # --------------------------------------------------
    # Validate pose model
    # --------------------------------------------------

    if not model_path.exists():
        raise FileNotFoundError(
            f"Pose model not found: {model_path}"
        )

    if not model_path.is_file():
        raise ValueError(
            f"Pose model path is not a file: {model_path}"
        )

    # --------------------------------------------------
    # Run CV pipeline
    # --------------------------------------------------

    result = analyze_squat_video(
        video_path,
        model_path,
    )

    # --------------------------------------------------
    # Return JSON-compatible result
    # --------------------------------------------------

    return result.to_dict()
