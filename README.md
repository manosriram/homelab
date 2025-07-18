## Homelab

![z](https://healthchecks.io/badge/a5ca2ccd-e4a3-40ed-bc4f-a9f1a4/XdRPXEIf-2.svg)

The diagram is the representation of my homelab.
The entire thing is under tailscale daemon.

4 nodes - `Lenovo M720s (100.69.69.69)`, `Mac Mini M1 (100.96.176.55)`, `Macbook Pro M3 (100.89.49.39)`, `iPhone (100.126.199.89)`

1 Master Node - `Lenovo M720s (100.69.69.69)`

<img width="1454" height="780" alt="mano-homelab-network-diagram" src="https://github.com/user-attachments/assets/d21d1006-0273-4ed7-b2e0-a963f0118f3b" />

These services in the homelab (lenovo) are monitored by uptime kuma which including all services are running as docker compose services / docker containers:

1. Vaultwarden - Password manager
2. ntfy - Notification service: sends notifications to iphone on any service goes down
3. Portainer - View and manage all containers
4. Deluge - Torrent client. Download and places in /downloads folder which is later picked by Sonarr or Radarr
5. Sonarr - Download TV shows via Deluge
6. Radarr - Download movies via Deluge
7. Bazarr - Download subs if not present and place it in the media directory itself.
8. Nginx Proxy Manager - HTTPs and subdomain supplier
9. Immich - Photos and videos manager. Every photo is backed up from iPhone
10. Filestash - Filesystem viewer/editor with shareable links
11. Jellyfin - Watch all media downloaded from Sonarr/Radarr
12. Prowlarr - Manage indexers to get tv shows or movie torrents from.
13. Uptime Kuma - Watches for container health. Sends notification to ntfy when any service goes down.
14. Heimdall - Homepage for all above services

Uptime kuma is itself monitored by external healthchecks.io to avoid single point of failure. healthchecks.io sends a ntfy notification as well when Uptime Kuma goes down.

Node specs:
1. Lenovo M720s - i5 8th gen, 64gb RAM, 128GB Internal SSD, 1TB External SSD. Acts as master node where the entire homelab is hosted.
2. Mac-Mini-M1 - 16GB Ram, M1 Chip
3. Macbook-pro - 18GB RAM, M3 Pro Chip
4. iPhone12


<img width="1287" height="874" alt="mano-homelab-docker-diagram" src="https://github.com/user-attachments/assets/04452dfc-3ad4-476c-8c4d-fb8ac8dc586d" />

1. [scripts/up.sh](https://github.com/manosriram/homelab/blob/master/scripts/up.sh): Does `docker compose up <container_name> -d` recursively to all *.docker-compose.yml files in the given directory.
2. [scripts/down.sh](https://github.com/manosriram/homelab/blob/master/scripts/down.sh): Does `docker compose down` recursively to all *.docker-compose.yml files in the given directory.
