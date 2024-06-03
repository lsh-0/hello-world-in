caddy-deps:
    pkg.installed:
        - pkgs:
            - debian-keyring
            - debian-archive-keyring
            - apt-transport-https

caddy-gpg-present:
    cmd.run:
        - name: |
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
        - unless:
            - test -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg

caddy-pkg-list-present:
    cmd.run:
        - name: |
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
        - unless:
            - test -f /etc/apt/sources.list.d/caddy-stable.list

install caddy:
    pkg.installed:
        - name: caddy
        - refresh: true # apt-get update prior to installation
        - require:
            - caddy-deps
            - caddy-gpg-present
            - caddy-pkg-list-present

remove the default welcome page:
    file.absent:
        - name: /etc/caddy/Caddyfile

link in the ./html directory on the host:
    file.managed:
        - source: /vagrant/caddy/Caddyfile
        - name: /etc/caddy/Caddyfile

validate config:
    cmd.run:
        - name: caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

caddy:
    service.running:
        - name: caddy
        - enable: true
        - require:
            - install caddy
            - remove the default welcome page
            - link in the ./html directory on the host
            - validate config
        - listen:
            - link in the ./html directory on the host

