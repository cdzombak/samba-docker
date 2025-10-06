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

### Elasticsearch & FSCrawler (for Spotlight support)

*TK*

*TK: cpu shares for the ES stuff; and (io)nice values for the same.*

> [!NOTE]
> Elasticsearch 8.9.0 and newer **are not compatible with Samba <= 4.18.** Fixed in 4.19 and 4.20: https://bugzilla.samba.org/show_bug.cgi?id=15611

## Monitoring with Netdata

*TK*

- https://www.netdata.cloud/monitoring-101/samba-monitoring/

## See Also

### Samba

- [`smb.conf` reference](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)
- [`smbd` reference](https://www.samba.org/samba/docs/current/man-html/smbd.8.html)
- [`smbpasswd` reference](https://www.samba.org/samba/docs/current/man-html/smbpasswd.8.html)
- https://wiki.samba.org/index.php/Build_Samba_from_Source
- https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html
- https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
- https://wiki.samba.org/index.php/Configuring_Logging_on_a_Samba_Server

### Elasticsearch and Spotlight

- https://wiki.samba.org/index.php/Spotlight_with_Elasticsearch_Backend
- https://bugzilla.samba.org/show_bug.cgi?id=15511
- https://bugzilla.samba.org/show_bug.cgi?id=15342
- https://github.com/Ellerhold/fs2es-indexer/issues/27#issuecomment-1676052344
- https://lists.samba.org/archive/samba/2023-August/246274.html
- https://fscrawler.readthedocs.io/en/latest

## License

Original works in this repo are licensed under GPL3; see `LICENSE` in this repo.

## Author

[Chris Dzombak](https://www.dzombak.com) ([github.com/cdzombak](https://www.github.com/cdzombak))
