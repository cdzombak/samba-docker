# samba-docker

> [!WARNING]
> This is a work in progress. The configuration published here does not exactly match the working config on my NAS, documentation is incomplete, and prebuilt Docker images are not available.
>
> See [TODO.md](https://github.com/cdzombak/samba-docker/blob/main/TODO.md) in this repository.

Up-to-date Samba Docker image optimized for NAS file sharing with full macOS Spotlight support.

## Configuration & Usage

tk

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

### Elasticsearch & FSCrawler (for Spotlight support)

tk

also TK: cpu shares for the ES stuff; and (io)nice values for the same.

## Monitoring with Netdata

tk

## Migrating away from system Samba

TK: necessary if you want samba container to use host networking and listen on 445

```
apt remove smbclient samba samba-common && apt autoremove
```

## See Also

tk: raindrop bookmarks

### Samba

tk: samba docs in general: smbd, conf, build, general wiki refs

- [`smb.conf` reference](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)
- [`smbd` reference](https://www.samba.org/samba/docs/current/man-html/smbd.8.html)
- [`smbpasswd` reference](https://www.samba.org/samba/docs/current/man-html/smbpasswd.8.html)
- https://wiki.samba.org/index.php/Build_Samba_from_Source
- https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html
- https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
- https://wiki.samba.org/index.php/Configuring_Logging_on_a_Samba_Server

### Elasticsearch and Spotlight

n.b. Elasticsearch 8.9.0 and newer **are not compatible with Samba**.

tk: spotlight, es,
indexers, samba bugs

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
