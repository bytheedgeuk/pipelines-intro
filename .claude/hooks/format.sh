#!/bin/sh
# Runs after every Edit/Write: formats just the file Claude touched.
# Silently skips if the formatter isn't installed or the file type doesn't match.
file=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] && [ -f "$file" ] || exit 0
case "$file" in
  *.c|*.cpp|*.h|*.hpp)
    command -v clang-format >/dev/null && clang-format -i "$file" ;;
  *.py)
    command -v ruff >/dev/null && ruff format -q "$file" ;;
esac
exit 0
