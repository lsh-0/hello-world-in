# essentially a SaltStack version of ./vagrant/nginx.sh

install nginx:
    pkg.installed:
        - name: nginx

remove the default welcome page:
    file.absent:
        - name: /etc/nginx/sites-enabled/default

link in the ./html directory on the host:
    file.managed:
        - source: /vagrant/nginx/default.conf
        - name: /etc/nginx/sites-enabled/default.conf

test the config:
    cmd.run:
        - name: nginx -t

nginx:
    service.running:
        - name: nginx
        - enable: true
        - require:
            - install nginx
            - remove the default welcome page
            - link in the ./html directory on the host
            - test the config
        - watch:
            - link in the ./html directory on the host

