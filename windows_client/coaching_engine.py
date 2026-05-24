from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any, Dict, List


@dataclass
class CoachCard:
    severity: str
    title: str
    message: str


class CoachingEngine:
    """AI wrapper with local heuristic fallback."""

    def __init__(self) -> None:
        self.groq_key = os.getenv("GROQ_API_KEY", "")
        self.gemini_key = os.getenv("GEMINI_API_KEY", "")
        self.openrouter_key = os.getenv("OPENROUTER_API_KEY", "")

    def _local_rules(self, telemetry: Dict[str, Any]) -> List[CoachCard]:
        cards: List[CoachCard] = []
        hs = float(telemetry.get("headshot_pct", 0))
        team_avg_credits = int(telemetry.get("team_avg_credits", 0))
        tilt = float(telemetry.get("tilt_level", 0))

        if team_avg_credits <= 1500:
            cards.append(
                CoachCard(
                    severity="warning",
                    title="Economy Alert",
                    message="Team economy is low. Consider light shield + sheriff.",
                )
            )
        if hs < 10:
            cards.append(
                CoachCard(
                    severity="tactical",
                    title="Aim Warning",
                    message="Headshot rate is below 10%. Hold crosshair at head height.",
                )
            )
        if tilt > 70:
            cards.append(
                CoachCard(
                    severity="critical",
                    title="Tilt Detected",
                    message="Take a breath and slow your peeks for next engagements.",
                )
            )
        if not cards:
            cards.append(
                CoachCard(
                    severity="positive",
                    title="Stable Performance",
                    message="Keep current tempo and communication discipline.",
                )
            )
        return cards

    def generate_cards(self, telemetry: Dict[str, Any]) -> List[Dict[str, str]]:
        # Placeholder: API backends can be integrated here.
        cards = self._local_rules(telemetry)
        return [card.__dict__ for card in cards]
