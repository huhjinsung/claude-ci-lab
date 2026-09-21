#!/bin/bash
# my-review.sh <커밋범위> - 로컬 코드 리뷰 봇
set -euo pipefail
RANGE="${1:?Usage: ./my-review.sh <commit-range>  예: HEAD~1..HEAD}"

echo "1) diff 수집: $RANGE"
DIFF=$(git diff "$RANGE")
[ -z "$DIFF" ] && { echo "diff 없음"; exit 0; }

echo "2) Claude 리뷰 실행..."
RESULT=$(echo "$DIFF" | claude -p "$(cat <<'PROMPT'
다음 stdin으로 전달된 diff를 리뷰하세요.
관점: 1) 버그 위험 2) 보안 3) 테스트 필요성
각 지적은 "- [심각도] 파일: 내용" 형식, 심각도는 CRITICAL/WARN/INFO 중 하나.
심각한 문제가 없으면 "- [INFO] 특이사항 없음" 한 줄만.
PROMPT
)" --output-format json --max-turns 5 \
  --allowed-tools "Read" "Grep" "Glob")

echo "$RESULT" | jq -r '.result' > review.md
COST=$(echo "$RESULT" | jq -r '.total_cost_usd')
echo "3) 저장: review.md (비용: \$$COST)"

if grep -q "CRITICAL" review.md; then
  echo "4) CRITICAL 발견 → exit 1 (게이트 차단 신호)"
  exit 1
fi
echo "4) 통과"
