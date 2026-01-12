#!/usr/bin/env bash
set -euo pipefail

EXT="${EXT:-mp4}"
TRIM_MODE="${TRIM_MODE:-start}"   # start | end | both
SKIP_START_SECS="${SKIP_START_SECS:-0}"
SKIP_END_SECS="${SKIP_END_SECS:-0}"
FFMPEG_BIN="${FFMPEG_BIN:-ffmpeg}"
FFPROBE_BIN="${FFPROBE_BIN:-ffprobe}"

shopt -s nullglob
mkdir -p Trimmed

files=(*."${EXT}")
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No .${EXT} files found."
  exit 0
fi

for file in "${files[@]}"; do
  duration=$("${FFPROBE_BIN}" -v error -of default=noprint_wrappers=1:nokey=1 -show_entries format=duration "$file")

  case "${TRIM_MODE}" in
    start)
      start_skip=${SKIP_START_SECS}
      trimmed_length=$(echo "${duration} - ${start_skip}" | bc -l)
      if (( $(echo "${trimmed_length} <= 0" | bc -l) )); then
        echo "Skipping ${file} (shorter than ${start_skip}s start trim)."
        continue
      fi
      trimmed_length=$(printf "%.3f" "${trimmed_length}")
      start_ts=$(printf "%.3f" "${start_skip}")

      "${FFMPEG_BIN}" -hide_banner -loglevel warning -i "$file" \
        -ss "${start_ts}" -t "${trimmed_length}" \
        -c:v copy -c:a copy "Trimmed/${file}"
      ;;

    end)
      end_skip=${SKIP_END_SECS}
      trimmed_length=$(echo "${duration} - ${end_skip}" | bc -l)
      if (( $(echo "${trimmed_length} <= 0" | bc -l) )); then
        echo "Skipping ${file} (shorter than ${end_skip}s end trim)."
        continue
      fi
      trimmed_length=$(printf "%.3f" "${trimmed_length}")

      "${FFMPEG_BIN}" -hide_banner -loglevel warning -i "$file" \
        -t "${trimmed_length}" \
        -c:v copy -c:a copy "Trimmed/${file}"
      ;;

    both)
      start_skip=${SKIP_START_SECS}
      end_skip=${SKIP_END_SECS}
      trimmed_length=$(echo "${duration} - ${start_skip} - ${end_skip}" | bc -l)
      if (( $(echo "${trimmed_length} <= 0" | bc -l) )); then
        echo "Skipping ${file} (shorter than start+end trims: ${start_skip}s + ${end_skip}s)."
        continue
      fi
      trimmed_length=$(printf "%.3f" "${trimmed_length}")
      start_ts=$(printf "%.3f" "${start_skip}")

      "${FFMPEG_BIN}" -hide_banner -loglevel warning -i "$file" \
        -ss "${start_ts}" -t "${trimmed_length}" \
        -c:v copy -c:a copy "Trimmed/${file}"
      ;;

    *)
      echo "Unsupported TRIM_MODE '${TRIM_MODE}'. Use start, end, or both."
      exit 1
      ;;
  esac
done
