#!/usr/bin/env python3
"""Minimal Harness Executor

Phase 파일을 순서대로 확인하고 다음 pending Phase를 Claude Code에 넘길 수 있는 프롬프트를 출력한다.
기본값은 안전 모드이며, 실제 자동 실행보다는 Phase 관리와 재개 지점을 만드는 용도다.
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PHASES_DIR = ROOT / "phases"
STATUS_FILE = PHASES_DIR / "status.json"


def load_status() -> dict:
    if STATUS_FILE.exists():
        return json.loads(STATUS_FILE.read_text(encoding="utf-8"))
    return {"task": None, "current_phase": None, "phases": [], "updated_at": None}


def save_status(status: dict) -> None:
    status["updated_at"] = datetime.now(timezone.utc).isoformat()
    STATUS_FILE.write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")


def phase_files() -> list[Path]:
    return sorted(
        p for p in PHASES_DIR.glob("*.md")
        if p.name.lower() not in {"readme.md"} and not p.name.startswith("_")
    )


def read_phase_state(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    for state in ["pending", "in_progress", "completed", "blocked", "error"]:
        if f"## 상태\n{state}" in text or f"## Status\n{state}" in text:
            return state
    return "pending"


def main() -> int:
    task = sys.argv[1] if len(sys.argv) > 1 else "manual"
    PHASES_DIR.mkdir(exist_ok=True)
    status = load_status()
    files = phase_files()

    if not files:
        print("No phase files found.")
        print("Run /harness first or create phases from phases/templates/phase-template.md")
        return 1

    phase_states = [{"file": p.name, "state": read_phase_state(p)} for p in files]
    next_phase = next((item for item in phase_states if item["state"] in {"pending", "error"}), None)

    status["task"] = task
    status["phases"] = phase_states
    status["current_phase"] = next_phase["file"] if next_phase else None
    save_status(status)

    print("=" * 56)
    print("Harness Executor")
    print(f"Task: {task}")
    print(f"Phases: {len(files)} | Pending/Error: {sum(1 for x in phase_states if x['state'] in {'pending', 'error'})}")
    print("=" * 56)
    for item in phase_states:
        marker = "✓" if item["state"] == "completed" else "•"
        print(f"{marker} {item['file']} [{item['state']}]")
    print("=" * 56)

    if next_phase:
        phase_path = PHASES_DIR / next_phase["file"]
        print("Next phase prompt:")
        print()
        print(f"CLAUDE.md와 관련 docs를 확인한 뒤, phases/{phase_path.name}만 수행해줘.")
        print("비사소한 수정 전에는 변경 예정 파일과 계획을 먼저 설명하고 승인 대기해줘.")
    else:
        print("Task completed: no pending phases.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
