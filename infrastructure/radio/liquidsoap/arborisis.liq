set("log.stdout", true)
set("log.file", false)

laravel_base_url = getenv("https://arborisis.com", "LARAVEL_BASE_URL")
radio_token = getenv("", "RADIO_INTERNAL_TOKEN")
now_playing_url_base = "#{laravel_base_url}/api/internal/radio/now-playing"
crossfade_seconds = float_of_string(getenv("4", "RADIO_CROSSFADE_SECONDS"))

icecast_host = getenv("icecast", "ICECAST_HOST")
icecast_port = int_of_string(getenv("8000", "ICECAST_PORT"))
icecast_password = getenv("", "ICECAST_SOURCE_PASSWORD")
icecast_mount = getenv("/arborisis.mp3", "ICECAST_MOUNT")

# Include generated playlist
%include "/radio-cache/playlist.liq"

def post_metadata(m)
  try
    sound_id = m["sound_id"] ?? ""
    kind = m["kind"] ?? "sound"
    podcast_id = m["podcast_id"] ?? ""
    show_type = m["show_type"] ?? ""

    url = now_playing_url_base ^ "?token=" ^ radio_token ^ "&sound_id=" ^ sound_id ^ "&kind=" ^ kind ^ "&podcast_id=" ^ podcast_id ^ "&show_type=" ^ show_type

    ignore(http.get(url))
  catch err do
    log("Now-playing post failed: #{err}")
  end
end

def enrich_meta(m)
  filename = m["filename"] ?? ""
  extra = list.assoc(default=[], filename, playlist_meta_lookup)
  if list.length(extra) > 0 then
    extra
  else
    m
  end
end

radio_playlist = mksafe(request.dynamic(id="arborisis_playlist", playlist_next_request))
radio_playlist = map_metadata(enrich_meta, radio_playlist)
radio_playlist = crossfade(duration=crossfade_seconds, radio_playlist)

silence_fallback = single("/radio/silence.mp3")
radio = fallback(track_sensitive=false, [radio_playlist, silence_fallback])

radio.on_metadata(post_metadata)
output.icecast(
  %mp3(bitrate=192, samplerate=44100, stereo=true),
  host=icecast_host,
  port=icecast_port,
  password=icecast_password,
  mount=icecast_mount,
  name="Arborisis Radio",
  genre="Field Recording / Nature",
  url=laravel_base_url,
  radio
)
