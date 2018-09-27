
## Bootstrapping

| Name         | Default         | Description                                                  |
| ------------ | --------------- | ------------------------------------------------------------ |
| ssh_key_user | ec2-user        | The name of the preconfigured user in the image              |
| ssh_key_full |                 | The SSH public key to install as an authorized key for `ssh_key_user` |
| git_repo     |                 |                                                              |
| git_branch   | master          |                                                              |
| git_path     | /etc/repository |                                                              |
| git_account  |                 | Optional: The AWS account that `git_repo` is hosted in       |
| git_role     |                 | Optional: An IAM role in `git_account` that has *codecommit* permissions on `git_repo` |
| phone_home   |                 | A bash snippet that gets executed at the end of bootstrapping - e.g. To execute an initial Ansible Tower playbook run |

A cloud-init file is specified on launch that provides:

1. Inserts the `ssh_key_full` public key into the `ssh_key_user`'s authorized_keys file
1. Formats and mounts any volumes that have mount params and adds them into `/etc/fstab`
1. Updates the hostname
1. Updates `/etc/environment` with the *role, purpose, purposeId, environment, region, domain, ami* values
1. Configures git to use the `git_account/git_role` IAM role for AWS CodeCommit checkouts (if specified)
1. Clones `git_repo` to `git_path` and installs any git hooks in the `.hooks` directory and execute the *post-merge* hook.
1. Installs a systemd service and timer `git-sync` that keeps the git repo in sync.
1. Executes the script specified in `phone_home`
