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