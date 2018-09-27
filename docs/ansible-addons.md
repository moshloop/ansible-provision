
Ansible Role for creating systemd services, for managing existing services use the built-in [systemd](https://docs.ansible.com/ansible/latest/modules/systemd_module.html) module.

## Filters

| name                                          | description                                                  |
| --------------------------------------------- | ------------------------------------------------------------ |
| **file_exists**(path)                         |                                                              |
| **dir_exists**(path)                          |                                                              |
| **jsonpath**(data)                            | transforms data using `jsonpath_rw`                            |
| **nestedelement**(path)                       | Returns an nested element from an object tree by path (seperated by / or .) |
| **play_groups**(play_hosts, groups, hostvars) | Returns a list of groups that are active within a play       |
| **split**(string, separator=' ')              |                                                              |
| **to_map**(map, key, value)                   |                                                              |
| **walk_up**(object, path)                     | Walks up an object tree from the lowest level collecting all attributes not available at lower levels |
| **map_to_entries**(dict, key, value)          | Convert a dict into a list of entries                        |


## Modules

#### cloudinit_iso

```yaml
      - cloudinit_iso:
          dest: "{{playbook_dir}}/cloudinit.iso"
          user: |
            #cloud-config
            preserve_hostname: true
            hostname: ansible-hostname
            users:
                - name: hostname
```

!!! note
    **cloudinit_iso** requires the `genisoimage` package to be installed.
