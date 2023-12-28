# samba-docker

> [!WARNING]
> This is a work in progress. The configuration published here does not exactly match the working config on my NAS, documentation is incomplete, and prebuilt Docker images are not available.
>
> See [TODO.md](https://github.com/cdzombak/samba-docker/blob/main/TODO.md) in this repository.

Up-to-date Samba Docker image optimized for NAS file sharing with full macOS Spotlight support.

## Configuration & Usage

tk

### Using `testparm`

With your `docker-compose.yml` configured, you can use [`testparm`](https://www.samba.org/samba/docs/current/man-html/testparm.1.html) as follows to check your `smb.conf`:

```shell
docker compose run samba testparm /usr/local/samba/etc/smb.conf
```

## Monitoring with Netdata

tk

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
