# Build Server SSH Config
Modified: 2021-02

The build server requires ssh deploy keys that are registered with `Incuvers/monitor` and `Incuvers/icb` to pull the `icb` and `monitor` parts. The same ssh deploy key cannot be used across both repositories for security reasons. To circumvent this we create two ssh key pairs:
```bash
ssh-keygen -b 4096 -t rsa -f "$HOME"/.ssh/monitor_deploy_key -q -N ""

ssh-keygen -b 4096 -t rsa -f "$HOME"/.ssh/icb_deploy_key -q -N ""
```

We then reference these keys through an alias defined in `.ssh/config`:
```ini
Host github.com-monitor
        Hostname github.com
        IdentityFile=/home/user/.ssh/monitor_deploy_key

Host github.com-icb
        Hostname github.com
        IdentityFile=/home/user/.ssh/icb_deploy_key
```

## Snapcraft pull source
In the snapcraft file we reference the github deploy key for a repository via the alias host:
```yaml
monitor:
    plugin: python
    source-type: git
    source-branch: develop
    source-depth: 1
    source: git@github.com-monitor:Incuvers/monitor.git
    ...

icb:
    plugin: nil
    source-type: git
    source-branch: master
    source-depth: 1
    source: git@github.com-icb:Incuvers/icb.git
    ...
```