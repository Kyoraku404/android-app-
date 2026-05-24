from __future__ import annotations

import random
from typing import Any, Dict


class ScreenParser:
    """Live parser interface for MSS/OpenCV integration.

    This returns synthetic-but-dynamic values now and is structured to be
    replaced by ROI extraction calls without changing API consumers.
    """

    def capture_and_parse(self) -> Dict[str, Any]:
        return {
            "kills": random.randint(0, 25),
            "deaths": random.randint(0, 20),
            "assists": random.randint(0, 15),
            "headshot_pct": round(random.uniform(8.0, 42.0), 1),
            "round_time": random.choice(["01:40", "01:10", "00:43", "00:19"]),
            "weapon": random.choice(["Vandal", "Phantom", "Sheriff", "Operator"]),
            "aim_score": random.randint(30, 95),
            "fps": random.randint(110, 360),
        }
