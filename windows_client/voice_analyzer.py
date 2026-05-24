from __future__ import annotations

from random import randint


class VoiceAnalyzer:
    """Stub analyzer returning synthetic tilt/stress metrics."""

    def current_metrics(self) -> dict:
        stress = randint(20, 85)
        return {
            "voice_rms": round(stress / 100, 2),
            "tilt_level": stress,
            "rage_risk": "high" if stress > 75 else "moderate" if stress > 50 else "low",
        }
