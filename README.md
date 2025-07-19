# My Homelab Setup ![mano homelab healthchecks.io status](https://healthchecks.io/b/2/e43c7200-d369-4bb2-929a-6d9ba4d1af09.svg)

Welcome to my personal homelab documentation! This README outlines the architecture, services, and management scripts for my home server environment. The entire setup is unified under a **Tailscale** daemon for secure and easy access.

---

## Network Diagram

The diagram below illustrates the interconnectedness of my homelab nodes:

<img width="1454" height="780" alt="mano-homelab-network-diagram" src="https://github.com/user-attachments/assets/d21d1006-0273-4ed7-b2e0-a963f0118f3b" />

**Current Nodes & Tailscale IPs:**

* **Lenovo M720s (Master Node):** `100.69.69.69`
* **Mac Mini M1:** `100.96.176.55`
* **Macbook Pro M3:** `100.89.49.39`
* **iPhone:** `100.126.199.89`
* **Raspberry Pi 4 (Slave Node):** Currently offline.

**Future Plans:**

* Actively integrate the **Raspberry Pi 4** (slave node) alongside the master node to leverage its capabilities.

---

## Services Running on Lenovo M720s (Master Node)

All services on the Lenovo M720s are orchestrated using **Docker Compose** and are monitored by **Uptime Kuma**.

<img width="1287" height="874" alt="mano-homelab-docker-diagram" src="https://github.com/user-attachments/assets/04452dfc-3ad4-476c-8c4d-fb8ac8dc586d" />

Here's a list of the services:

1.  **Vaultwarden:** A secure password manager for all my credentials.
2.  **ntfy:** My centralized notification service, sending alerts to my iPhone for any service downtime.
3.  **Portainer:** Provides a web-based UI to view and manage all Docker containers.
4.  **Deluge:** My torrent client, automatically placing downloaded content into the `/downloads` folder for further processing.
5.  **Sonarr:** Manages and downloads TV shows, integrating with Deluge.
6.  **Radarr:** Manages and downloads movies, integrating with Deluge.
7.  **Bazarr:** Automatically downloads subtitles for my media library if they're not already present.
8.  **Nginx Proxy Manager:** Handles HTTPS termination and subdomain routing for all services.
9.  **Immich:** A personal photo and video management solution, ensuring all photos from my iPhone are backed up.
10. **Filestash:** A web-based file system viewer/editor with support for shareable links.
11. **Jellyfin:** My personal media server for streaming all downloaded TV shows and movies.
12. **Prowlarr:** Manages and integrates various indexers to source torrents for Sonarr and Radarr.
13. **Uptime Kuma:** Monitors the health of all Docker containers and sends notifications via ntfy when a service goes down.

---

## Node Specifications

Here are the detailed specifications for each node in my homelab:

1.  **Lenovo M720s:**
    * **CPU:** Intel Core i5 8th Gen
    * **RAM:** 64GB
    * **Storage:** 128GB Internal SSD, 1TB External SSD
    * **OS:** Headless Debian
    * **Role:** Master node, hosting the entire homelab.

2.  **Raspberry Pi 4:**
    * **RAM:** 8GB
    * **CPU:** Broadcom BCM2711, Quad-core Cortex-A72 (ARM v8) 64-bit

3.  **Mac Mini M1:**
    * **RAM:** 16GB
    * **Chip:** Apple M1

4.  **Macbook Pro:**
    * **RAM:** 18GB
    * **Chip:** Apple M3 Pro

5.  **iPhone:**
    * **Model:** iPhone 12

---

## Management Scripts

I use simple shell scripts to manage the Docker Compose services:

* **`scripts/up.sh`**:
    This script recursively executes `docker compose up <container_name> -d` for all `*.docker-compose.yml` files found in a given directory, bringing services online.
    * [View `up.sh` on GitHub](https://github.com/manosriram/homelab/blob/master/scripts/up.sh)

* **`scripts/down.sh`**:
    This script recursively executes `docker compose down` for all `*.docker-compose.yml` files, taking services offline.
    * [View `down.sh` on GitHub](https://github.com/manosriram/homelab/blob/master/scripts/down.sh)
