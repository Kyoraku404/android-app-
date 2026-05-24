# VANTA LIVE

VANTA LIVE is a local-first AI esports coaching system for VALORANT with:
- **Windows client** (Python + FastAPI + OpenCV + audio analysis)
- **Android dashboard** (Flutter + Riverpod + SQLite)

## Architecture

Windows client captures telemetry, runs heuristic/AI coaching, and streams JSON over WebSocket (`ws://<pc-ip>:8000/ws`) to Android over local Wi-Fi.

## Windows client setup

1. Install Python 3.10+.
2. Install dependencies:
   ```bash
   cd windows_client
   pip install -r requirements.txt
   ```
3. Set optional API keys:
   - `GROQ_API_KEY`
   - `GEMINI_API_KEY`
   - `OPENROUTER_API_KEY`
4. Start server:
   ```bash
   python main.py
   ```

### Networking requirements
- Server binds to `0.0.0.0:8000`.
- Allow inbound TCP **8000** in Windows Firewall.

### Simulator mode
Run with simulator on by default, or toggle in `main.py`:
```bash
python main.py
```

## Android app setup

1. Install Flutter stable SDK.
2. Install packages:
   ```bash
   cd android_app
   flutter pub get
   ```
3. Run app:
   ```bash
   flutter run
   ```

## Verification checklist

- Pairing code validation succeeds.
- WebSocket messages stream continuously.
- With no API keys, local heuristic coaching cards still appear.
- Match simulator drives dashboard updates (KDA, tilt, economy).

## Open question
Initial heatmap templates include **Haven, Ascent, Bind, Icebox**. Confirm whether additional maps are needed for v1.
