from pathlib import Path

from app.preprocessing.video_processor import VideoProcessor


VIDEO_PATH = (
    Path(__file__).resolve().parent.parent
    / "videos"
    / "squat"
    / "SquatExerciseVideo.mp4"
)


def main():
    print(f"Testing video: {VIDEO_PATH}")
    print()

    with VideoProcessor(VIDEO_PATH) as processor:
        metadata = processor.get_metadata()

        print("Video metadata")
        print("----------------------------")
        print(f"Width:             {metadata.width}")
        print(f"Height:            {metadata.height}")
        print(f"FPS:               {metadata.fps:.2f}")
        print(f"Frame count:       {metadata.frame_count}")
        print(f"Duration:          {metadata.duration_seconds:.2f} seconds")
        print()

        frame = processor.read_frame()

        if frame is None:
            print("ERROR: Could not read first frame.")
            return

        print(
            f"First frame shape: {frame.shape}"
        )
        print("Video preprocessing test: PASSED")


if __name__ == "__main__":
    main()