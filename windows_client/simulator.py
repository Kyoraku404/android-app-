from __future__ import annotations

import random
from dataclasses import dataclass, asdict
from typing import Any, Dict


@dataclass
class SimState:
    kills: int = 0
    deaths: int = 0
    assists: int = 0
    headshot_pct: float = 20.0
    team_avg_credits: int = 2800
    enemy_avg_credits: int = 3000
    round: int = 1
    aim_score: int = 70
    fps: int = 240

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


def next_state(prev: Dict[str, Any]) -> Dict[str, Any]:
    kills = int(prev.get("kills", 0)) + random.choice([0, 1])
    deaths = int(prev.get("deaths", 0)) + random.choice([0, 0, 1])
    assists = int(prev.get("assists", 0)) + random.choice([0, 1])
    hs = max(5.0, min(45.0, float(prev.get("headshot_pct", 20.0)) + random.uniform(-2.2, 2.4)))
    aim = max(20, min(100, int(prev.get("aim_score", 70)) + random.choice([-3, -2, -1, 0, 1, 2, 3])))
    fps = max(90, min(420, int(prev.get("fps", 240)) + random.choice([-8, -6, -2, 0, 2, 6, 8])))

    return {
        **prev,
        "kills": kills,
        "deaths": deaths,
        "assists": assists,
        "headshot_pct": round(hs, 1),
        "team_avg_credits": random.randint(800, 4600),
        "enemy_avg_credits": random.randint(800, 4600),
        "round": min(24, int(prev.get("round", 1)) + random.choice([0, 1])),
        "aim_score": aim,
        "fps": fps,
    }
