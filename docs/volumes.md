# Storage

### Volumes

```yaml
volumes:
    - {}
```

| Name   | Default | Description                                                  |
| ------ | ------- | ------------------------------------------------------------ |
| size   |         | Size in GB of the volume                                     |
| id     |         | The name of the volume e.g. volume it will be used as suffix |
| dev    |         | The unique device path to use e.g. */dev/xvf*, *host:/nfs_mount* |
| type   | gp2     |                                                              |
| format |         | Optional: Partition type e.g. *xfs*, *lvm*, *nfs*                  |
| mount  |         | Optional: Mount point for the volume e.g. */mnt/volume*        |


### LVM

LVM volumes are supported are supported:

1. To create an physical volume specify `format: lvm` and the volume name under `mount: VolName `
2. Then add another volume with `dev: VolName`

!!! example ""
    !!! example ""
    **Example: create a 200GB volume called VolData, format it with xfs and then mount under /pgdata**

    ``` yaml
    volumes:
      - {size: 201, id: data, dev: /dev/xvdf, format: lvm, mount: VolData}
      - {size: 200, id: data-pgdata, dev: VolData, format: xfs, mount: /pgdata}
    ```

!!! example ""
    **Example: Creating 3 LVM volumes for Postgres**

    ``` yaml
    volumes:
      - {size: 201, id: data, dev: /dev/xvdf, format: lvm, mount: VolData}
      - {size: 200, id: data-pgdata, dev: VolData, format: xfs, mount: /pgdata}
      - {size: 101, id: backups, dev: /dev/xvdg, format: lvm, mount: VolBackups}
      - {size: 100, id: backups-data, dev: VolBackups, format: xfs, mount: /pgbackups}
      - {size: 51, id: wal, dev: /dev/xvdh, format: lvm, mount: VolWAL}
      - {size: 50, id: wal-share, dev: VolWAL, format: xfs, mount: /pgwal}
    ```
    **result:**
    ```bash
    $ df -h
    Filesystem                         Size  Used Avail Use% Mounted on
    ...
    /dev/mapper/VolData-_pgdata        200G   33M  200G   1% /pgdata
    /dev/mapper/VolBackups-_pgbackups  100G   33M  100G   1% /pgbackups
    /dev/mapper/VolWAL-_pgwal           50G   33M   50G   1% /pgwal
    ```

!!! warning
    Due to some differences in sizing it is recommended to make LVM logical volumes 1GB smaller than the physical volume
### Instance Volume

```yaml
instance_volumes:
    - {}
```

| Name   | Default | Description |
| ------ | ------- | ----------- |
| dev    |         |             |
| format |         |             |
| mount  |         |             |