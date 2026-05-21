# Arborisis Radio

Cette stack remplace le stream Laravel maison par un vrai moteur radio :

- Icecast expose le flux public MP3.
- Liquidsoap récupère la playlist Laravel et pousse les métadonnées now-playing.
- Laravel reste le manager : catalogue, DJ ElevenLabs, état live, Discord.

## Setup

```bash
cd infrastructure/radio
cp .env.example .env
docker compose up -d
```

Variables Laravel minimales :

```env
RADIO_ENGINE=icecast
RADIO_INTERNAL_TOKEN=change-me
RADIO_PUBLIC_STREAM_URL=https://radio.arborisis.com/arborisis.mp3
ICECAST_BASE_URL=http://127.0.0.1:8010
ICECAST_MOUNT=/arborisis.mp3
ELEVENLABS_API_KEY=
ELEVENLABS_VOICE_ID=
DISCORD_RADIO_VOICE_CHANNEL_ID=
DISCORD_RADIO_AUTO_JOIN=true
```

Liquidsoap appelle :

- `GET /api/internal/radio/playlist?format=m3u`
- `POST /api/internal/radio/now-playing`
- `GET /api/internal/radio/status`

Chaque appel doit envoyer `Authorization: Bearer RADIO_INTERNAL_TOKEN`.
