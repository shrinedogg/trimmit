# Trimmit

Trim batches of videos without re-encoding. Both scripts read all files matching the chosen extension in the current directory and write trimmed copies to `Trimmed/`.

## Requirements
- Windows: `ffmpeg.exe` and `ffprobe.exe` on PATH, or set `ffmpeg_dir` to the folder containing the ffmpeg executable.
- Linux: `ffmpeg` and `ffprobe` on PATH; `bc` for float math.

## Windows (.bat)
1. Place `trimmit.bat` with your videos.
2. Open Command Prompt or PowerShell in that folder.
3. Run: `trimmit.bat`

Configurable variables at the top of the script:
- `ext`: file extension to process (default `mp4`).
- `trim_mode`: `start`, `end`, or `both`.
- `skip_start_sec`: seconds to remove from the beginning.
- `skip_end_sec`: seconds to remove from the end.
- `trim_start_ms`: millisecond offset for the start timestamp.
- `ffmpeg_dir`: optional path to the folder containing `ffmpeg.exe` and `ffprobe.exe`.

Behavior:
- Skips files shorter than the requested trims.
- Keeps audio/video streams intact (`-c copy`).
- Writes results to `Trimmed/<originalname>`. Creates the folder if missing.

## Linux (.sh)
1. Place `trimmit.sh` with your videos and make it executable: `chmod +x trimmit.sh`.
2. Run: `./trimmit.sh`

Optional environment overrides (export before running):
- `EXT` (default `mp4`).
- `TRIM_MODE` (`start`, `end`, `both`).
- `SKIP_START_SECS`, `SKIP_END_SECS`.
- `FFMPEG_BIN`, `FFPROBE_BIN` (custom binary paths).

Behavior mirrors the Windows script: skips too-short files, copies streams without re-encoding, and writes to `Trimmed/`.

## Examples
- Trim first 3 seconds on Windows: `trimmit.bat`.
- Trim last 3 seconds on Linux: `TRIM_MODE=end SKIP_END_SECS=3 ./trimmit.sh`.
- Trim 2 seconds from start and 1 second from end on Linux: `TRIM_MODE=both SKIP_START_SECS=2 SKIP_END_SECS=1 ./trimmit.sh`.

## Notes
- **Run from the directory containing only the videos you wish to trim to avoid traversing subfolders**.
- Originals stay untouched; outputs land in `Trimmed/`.
- For other formats (e.g., `mkv`), change `ext`/`EXT` accordingly.
