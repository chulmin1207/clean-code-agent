#!/bin/bash
# Clean Code Agent 설치 스크립트
# 사용법: bash install.sh [대상 프로젝트 경로]
# 예시:   bash install.sh /path/to/my-project
#         bash install.sh .                      ← 현재 디렉토리

set -e

TARGET="${1:-.}"
TARGET=$(cd "$TARGET" && pwd)
SOURCE="$(cd "$(dirname "$0")" && pwd)"

echo "Clean Code Agent 설치"
echo "대상: $TARGET"
echo ""

# 1. .claude 디렉토리 복사
mkdir -p "$TARGET/.claude/agents" "$TARGET/.claude/commands"

cp "$SOURCE/.claude/agents/clean-code.md" "$TARGET/.claude/agents/clean-code.md"
echo "✓ .claude/agents/clean-code.md"

cp "$SOURCE/.claude/commands/clean.md" "$TARGET/.claude/commands/clean.md"
echo "✓ .claude/commands/clean.md"

cp "$SOURCE/.claude/commands/review.md" "$TARGET/.claude/commands/review.md"
echo "✓ .claude/commands/review.md"

cp "$SOURCE/.claude/commands/refactor.md" "$TARGET/.claude/commands/refactor.md"
echo "✓ .claude/commands/refactor.md"

cp "$SOURCE/.claude/commands/architect.md" "$TARGET/.claude/commands/architect.md"
echo "✓ .claude/commands/architect.md"

# 2. settings.json — 이미 있으면 건드리지 않음
if [ ! -f "$TARGET/.claude/settings.json" ]; then
  cp "$SOURCE/.claude/settings.json" "$TARGET/.claude/settings.json"
  echo "✓ .claude/settings.json (새로 생성)"
else
  echo "⊘ .claude/settings.json (이미 존재 — 건너뜀)"
fi

# 3. CLAUDE.md — 이미 있으면 끝에 추가할지 물어봄
if [ ! -f "$TARGET/CLAUDE.md" ]; then
  cp "$SOURCE/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "✓ CLAUDE.md (새로 생성)"
else
  echo ""
  echo "CLAUDE.md가 이미 존재합니다."
  echo "  1) 끝에 추가 (append)"
  echo "  2) 건너뛰기 (skip)"
  echo "  3) 덮어쓰기 (overwrite)"
  read -rp "선택 [1/2/3]: " choice || choice="2"
  case "$choice" in
    1)
      echo "" >> "$TARGET/CLAUDE.md"
      echo "---" >> "$TARGET/CLAUDE.md"
      echo "" >> "$TARGET/CLAUDE.md"
      cat "$SOURCE/CLAUDE.md" >> "$TARGET/CLAUDE.md"
      echo "✓ CLAUDE.md (끝에 추가)"
      ;;
    3)
      cp "$SOURCE/CLAUDE.md" "$TARGET/CLAUDE.md"
      echo "✓ CLAUDE.md (덮어쓰기)"
      ;;
    *)
      echo "⊘ CLAUDE.md (건너뜀)"
      ;;
  esac
fi

# 4. AGENTS.md 심볼릭 링크 (Codex CLI 호환)
if [ ! -f "$TARGET/AGENTS.md" ]; then
  ln -s CLAUDE.md "$TARGET/AGENTS.md"
  echo "✓ AGENTS.md → CLAUDE.md 링크"
else
  echo "⊘ AGENTS.md (이미 존재 — 건너뜀)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 설치 완료!"
echo ""
echo " 사용법:"
echo "   /clean              변경사항 검사"
echo "   /review src/app.ts  파일 리뷰"
echo "   /review src/        디렉토리 리뷰"
echo "   /refactor src/app.ts 리팩토링"
echo "   /architect src/     아키텍처 분석"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
