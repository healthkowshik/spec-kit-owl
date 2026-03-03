#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Owl Metrics — Spec vs Code line & character counts
# ============================================================

BREAKDOWN=false

# --- Argument parsing ---
for arg in "$@"; do
  case "$arg" in
    --breakdown) BREAKDOWN=true ;;
  esac
done

# --- File enumeration ---
# Use git ls-files if inside a git repo, otherwise fall back to find.
enumerate_files() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git ls-files --cached --others --exclude-standard
  else
    find . -type f -not -path './.git/*' | sed 's|^\./||'
  fi
}

# --- Helpers ---

is_binary() {
  local file="$1"
  # Check first 8KB for null bytes
  local nulls
  nulls=$(head -c 8192 "$file" 2>/dev/null | tr -cd '\0' | wc -c)
  [ "$nulls" -gt 0 ]
}

is_symlink() {
  [ -L "$1" ]
}

is_spec_path() {
  local path="$1"
  case "$path" in
    specs/*|.specify/*) return 0 ;;
    *) return 1 ;;
  esac
}

count_lines() {
  local file="$1"
  local size
  size=$(wc -c < "$file" | tr -d ' ')
  if [ "$size" -eq 0 ]; then
    echo 0
    return
  fi
  # Count newlines, add 1 if file doesn't end with newline
  local nl_count
  nl_count=$(wc -l < "$file" | tr -d ' ')
  local last_byte
  last_byte=$(tail -c 1 "$file" | wc -l | tr -d ' ')
  if [ "$last_byte" -eq 0 ] && [ "$size" -gt 0 ]; then
    nl_count=$((nl_count + 1))
  fi
  echo "$nl_count"
}

count_chars() {
  local file="$1"
  # Normalize \r\n to \n by stripping \r, then count bytes
  tr -d '\r' < "$file" | wc -c | tr -d ' '
}

format_number() {
  local n="$1"
  # Add comma-separated thousands using printf (portable)
  printf "%'d" "$n" 2>/dev/null || echo "$n"
}

calc_percentage() {
  local part="$1"
  local total="$2"
  if [ "$total" -eq 0 ]; then
    echo "N/A"
  else
    echo $(( (part * 100 + total / 2) / total ))"%"
  fi
}

# --- Accumulate metrics ---

declare -A DIR_LINES DIR_CHARS DIR_CATEGORY 2>/dev/null || true
spec_lines=0
spec_chars=0
non_spec_lines=0
non_spec_chars=0

# Track per-directory data in parallel arrays (portable)
dir_names=()
dir_lines_arr=()
dir_chars_arr=()
dir_categories=()

dir_index() {
  local name="$1"
  local i
  for i in "${!dir_names[@]}"; do
    if [ "${dir_names[$i]}" = "$name" ]; then
      echo "$i"
      return
    fi
  done
  echo "-1"
}

add_to_dir() {
  local dir="$1"
  local lines="$2"
  local chars="$3"
  local cat="$4"
  local idx
  idx=$(dir_index "$dir")
  if [ "$idx" -eq -1 ]; then
    dir_names+=("$dir")
    dir_lines_arr+=("$lines")
    dir_chars_arr+=("$chars")
    dir_categories+=("$cat")
  else
    dir_lines_arr[$idx]=$(( ${dir_lines_arr[$idx]} + lines ))
    dir_chars_arr[$idx]=$(( ${dir_chars_arr[$idx]} + chars ))
  fi
}

while IFS= read -r file; do
  # Skip if file doesn't exist, is a symlink, or is binary
  [ -f "$file" ] || continue
  is_symlink "$file" && continue
  is_binary "$file" && continue

  lines=$(count_lines "$file")
  chars=$(count_chars "$file")

  # Determine directory (first path component, or "." for root files)
  local_dir="."
  case "$file" in
    */*) local_dir="${file%%/*}" ;;
  esac
  # Add trailing slash for display (except ".")
  if [ "$local_dir" != "." ]; then
    display_dir="${local_dir}/"
  else
    display_dir="."
  fi

  if is_spec_path "$file"; then
    spec_lines=$((spec_lines + lines))
    spec_chars=$((spec_chars + chars))
    add_to_dir "$display_dir" "$lines" "$chars" "spec"
  else
    non_spec_lines=$((non_spec_lines + lines))
    non_spec_chars=$((non_spec_chars + chars))
    add_to_dir "$display_dir" "$lines" "$chars" "non-spec"
  fi
done < <(enumerate_files)

# --- Compute totals and percentages ---

total_lines=$((spec_lines + non_spec_lines))
total_chars=$((spec_chars + non_spec_chars))
line_pct=$(calc_percentage "$spec_lines" "$total_lines")
char_pct=$(calc_percentage "$spec_chars" "$total_chars")

# --- Summary output ---

fmt_spec_lines=$(format_number "$spec_lines")
fmt_spec_chars=$(format_number "$spec_chars")
fmt_non_spec_lines=$(format_number "$non_spec_lines")
fmt_non_spec_chars=$(format_number "$non_spec_chars")
fmt_total_lines=$(format_number "$total_lines")
fmt_total_chars=$(format_number "$total_chars")

printf 'Spec vs Code Metrics\n'
printf '====================\n'
printf '\n'
printf '  Spec lines:    %10s\n' "$fmt_spec_lines"
printf '  Spec chars:    %10s\n' "$fmt_spec_chars"
printf '  Non-spec lines:%10s\n' "$fmt_non_spec_lines"
printf '  Non-spec chars:%10s\n' "$fmt_non_spec_chars"
printf '\n'
printf '  Total lines:   %10s\n' "$fmt_total_lines"
printf '  Total chars:   %10s\n' "$fmt_total_chars"
printf '\n'
printf '  Spec %%:  Lines: %s  |  Chars: %s\n' "$line_pct" "$char_pct"

# --- Breakdown output ---

if [ "$BREAKDOWN" = true ]; then
  printf '\n'
  printf 'Breakdown by Directory\n'
  printf '======================\n'
  printf '\n'
  printf '  %-20s %-12s %8s %10s\n' "Directory" "Category" "Lines" "Chars"
  printf '  %-20s %-12s %8s %10s\n' "---------" "--------" "-----" "-----"

  # Sort: spec dirs first (alphabetical), then non-spec dirs (alphabetical)
  spec_dirs=()
  non_spec_dirs=()
  for i in "${!dir_names[@]}"; do
    if [ "${dir_categories[$i]}" = "spec" ]; then
      spec_dirs+=("$i")
    else
      non_spec_dirs+=("$i")
    fi
  done

  # Sort spec dirs alphabetically
  sorted_spec=()
  if [ ${#spec_dirs[@]} -gt 0 ]; then
    sorted_spec=($(for i in "${spec_dirs[@]}"; do echo "$i ${dir_names[$i]}"; done | sort -k2 | awk '{print $1}'))
  fi

  # Sort non-spec dirs alphabetically
  sorted_non_spec=()
  if [ ${#non_spec_dirs[@]} -gt 0 ]; then
    sorted_non_spec=($(for i in "${non_spec_dirs[@]}"; do echo "$i ${dir_names[$i]}"; done | sort -k2 | awk '{print $1}'))
  fi

  # Print spec dirs first, then non-spec
  for i in "${sorted_spec[@]+"${sorted_spec[@]}"}"; do
    [ -z "$i" ] && continue
    printf '  %-20s %-12s %8s %10s\n' \
      "${dir_names[$i]}" \
      "${dir_categories[$i]}" \
      "$(format_number "${dir_lines_arr[$i]}")" \
      "$(format_number "${dir_chars_arr[$i]}")"
  done
  for i in "${sorted_non_spec[@]+"${sorted_non_spec[@]}"}"; do
    [ -z "$i" ] && continue
    printf '  %-20s %-12s %8s %10s\n' \
      "${dir_names[$i]}" \
      "${dir_categories[$i]}" \
      "$(format_number "${dir_lines_arr[$i]}")" \
      "$(format_number "${dir_chars_arr[$i]}")"
  done
fi
