# samba-docker

Up-to-date Samba Docker image optimized for NAS file sharing with full macOS Spotlight support via Elasticsearch integration.

## Configuration & Usage

See `deploy-example` for an example `docker-compose.yml` and `smb.conf` setup. Docker Compose is recommended for deployment. Note that you'll need to mount a number of files/directories into the container, in addition to the Samba shares themselves:

```
      - /etc/passwd:/etc/passwd:ro
      - /etc/shadow:/etc/shadow:ro
      - /etc/group:/etc/group:ro
      - ./10-tz.sh:/etc/cont-init.d/10-tz.sh:ro  # set timezone
      - ./70-smbusers.sh:/etc/cont-init.d/70-smbusers.sh:ro  # set up SMB users
      - ./smb.conf:/usr/local/samba/etc/smb.conf:ro  # your smb.conf
      - /var/log/samba-docker:/usr/local/samba/var/log  # optional: Samba logs
```

The recommended usage is to remove Samba from the host and allow this container to bind directly to port 445 using host networking.

### Using `testparm`

With your `docker-compose.yml` set up, you can use [`testparm`](https://www.samba.org/samba/docs/current/man-html/testparm.1.html) as follows to check your `smb.conf`:

```shell
docker compose run samba testparm /usr/local/samba/etc/smb.conf
```

### IO and Nice Prioritization

Samba is arguably the most important thing running on my NAS; when I'm browsing files/folders on it, I want it to be _as fast as possible_. To help achieve this I've added the following to the `samba` service in my `docker-compose` file:

```
    command:
      - ionice
      - -c1
      - -n1
      - nice
      - -n-17
      - /usr/local/samba/sbin/smbd
      - --foreground
      - --no-process-group
      - --configfile
      - /usr/local/samba/etc/smb.conf
    cap_add:
      - CAP_SYS_NICE
```

This runs `smbd` in the "realtime" IO class, with priority `1` (the possible priorities are `0-7`, with lower numbers being higher priority). To give it priority on the CPU, I also give `smbd` a `nice` value of `-17` (values range down to `-19`, the highest priority).

### Migrating away from system Samba

This is necessary if you want the Samba container to use host networking and listen on port 445 (recommended).

```
apt remove smbclient samba samba-common && apt autoremove
```

### See Also

- [`smb.conf` reference](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)
- [`smbd` reference](https://www.samba.org/samba/docs/current/man-html/smbd.8.html)
- [`smbpasswd` reference](https://www.samba.org/samba/docs/current/man-html/smbpasswd.8.html)
- https://wiki.samba.org/index.php/Build_Samba_from_Source
- https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html
- https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
- https://wiki.samba.org/index.php/Configuring_Logging_on_a_Samba_Server

## Elasticsearch & FSCrawler (for Spotlight support)

To enable macOS Spotlight support, you'll need to set up an Elasticsearch instance and FSCrawler to index your Samba shares. See the `deploy-example/elasticsearch` directory for an example `docker-compose.yml` and configuration files, and `deploy-example/fscrawler` for an example FSCrawler setup.

Note that:

- Recent versions of Elasticsearch are not compatible with Samba. I have had luck using Elasticsearch 8.8.2 specifically.
- Samba does not support authenticating to Elasticsearch via Basic Auth or API Key. You'll need to allow anonymous users to query your fscrawler indexes, and use e.g. Tailscale to lock down access to your Elasticsearch instance.
- To make things easier, I have disabled HTTPS for my Elasticsearch instance. This is fine for me since it's only accessible over Tailscale; I recommend you do something similar. Otherwise you'll need to set up Samba to trust your Elasticsearch TLS certificate somehow (this might be easy if you let Tailscale handle certificate issuance; otherwise 🤷‍♂️).

The example stack in `deploy-example` handles all of this (except the Tailscale bits). For additional guidance and troubleshooting, see [my blog post on the topic](https://www.dzombak.com/blog/2025/10/setting-up-testing-spotlight-samba-elasticsearch/).

### See Also

- https://wiki.samba.org/index.php/Spotlight_with_Elasticsearch_Backend
- https://fscrawler.readthedocs.io/en/latest

#### Compatibility

- https://bugzilla.samba.org/show_bug.cgi?id=15511
- https://bugzilla.samba.org/show_bug.cgi?id=15342
- https://github.com/Ellerhold/fs2es-indexer/issues/27#issuecomment-1676052344
- https://lists.samba.org/archive/samba/2023-August/246274.html

## Monitoring with Netdata

*TK*

### See Also

- https://www.netdata.cloud/monitoring-101/samba-monitoring/

## License

Original works in this repo are licensed under GPL3; see [`LICENSE`](LICENSE) in this repo.

## Author

[Chris Dzombak](https://www.dzombak.com) ([github.com/cdzombak](https://www.github.com/cdzombak))
