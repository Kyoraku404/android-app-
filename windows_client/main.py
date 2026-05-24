from __future__ import annotations

import asyncio
import json
import random
import time
from typing import Any, Dict, Set

import uvicorn
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect

from coaching_engine import CoachingEngine
from screen_parser import ScreenParser
from simulator import SimState, next_state
from voice_analyzer import VoiceAnalyzer

app = FastAPI(title="VANTA LIVE Local Gateway")
clients: Set[WebSocket] = set()
pairing_code = f"{random.randint(0, 9999):04d}"
engine = CoachingEngine()
parser = ScreenParser()
voice = VoiceAnalyzer()
state: Dict[str, Any] = SimState().to_dict()
simulator_enabled = True


@app.get("/health")
def health() -> dict:
    return {
        "ok": True,
        "pairing_code": pairing_code,
        "clients": len(clients),
        "simulator_enabled": simulator_enabled,
    }


@app.post("/simulator/start")
def start_simulator() -> dict:
    global simulator_enabled
    simulator_enabled = True
    return {"ok": True, "simulator_enabled": simulator_enabled}


@app.post("/simulator/stop")
def stop_simulator() -> dict:
    global simulator_enabled
    simulator_enabled = False
    return {"ok": True, "simulator_enabled": simulator_enabled}


@app.websocket("/ws")
async def ws(websocket: WebSocket) -> None:
    sent_code = websocket.query_params.get("code", "")
    if sent_code != pairing_code:
        await websocket.close(code=1008, reason="Invalid pairing code")
        return

    await websocket.accept()
    clients.add(websocket)
    try:
        while True:
            _ = await websocket.receive_text()
    except WebSocketDisconnect:
        clients.discard(websocket)


def _build_live_state() -> Dict[str, Any]:
    hud = parser.capture_and_parse()
    audio = voice.current_metrics()
    merged = {**state, **hud, **audio}
    merged["aim_score"] = max(25, min(100, int(hud.get("aim_score", 70))))
    merged["fps"] = max(60, min(420, int(hud.get("fps", 240))))
    return merged


async def broadcast_loop() -> None:
    global state
    while True:
        tick_start = time.perf_counter()

        if simulator_enabled:
            state = next_state(state)
            state.update(voice.current_metrics())
        else:
            state = _build_live_state()

        cards = engine.generate_cards(state)
        packet = {
            "type": "telemetry",
            "pairing_code": pairing_code,
            "timestamp": time.time(),
            "payload": {**state, "coach_cards": cards},
        }

        dead = []
        for c in clients:
            try:
                await c.send_text(json.dumps(packet))
            except Exception:
                dead.append(c)
        for d in dead:
            clients.discard(d)

        elapsed = time.perf_counter() - tick_start
        await asyncio.sleep(max(0.2, 1.0 - elapsed))


@app.on_event("startup")
async def startup_event() -> None:
    asyncio.create_task(broadcast_loop())


if __name__ == "__main__":
    print(f"VANTA LIVE pairing code: {pairing_code}")
    uvicorn.run(app, host="0.0.0.0", port=8000)
