docker run -d \
  --name=radarr \
  -e PUID=100 \
  -e PGID=500 \
  -e TZ=Etc/UTC \
  -p 7878:7878 \
  -v /path/to/data:/config \
  -v /path/to/media:/media \
  --restart unless-stopped