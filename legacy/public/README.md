Steps taken:
- Initial Ubuntu
- Docker
- Move over services `rsync -rz . 45.79.76.80:~/services`
- Enable docker to start on boot
    `sudo systemctl enable docker.service`
    `sudo systemctl enable containerd.service`
- Open up web ports
  - `sudo ufw allow 80`
  - `sudo ufw allow 443`
- Fix docker-compose access (update playbook)
  - `sudo chmod +x /usr/local/bin/docker-compose`
- Create lan network
  - `sudo docker network create lan`
- Move over blog `rsync -rz code-captured/* 45.79.76.80:~/services/hugo/source`
- `docker-compose up -d` everything!

Traefik may need to change `chmod 600 acme.json`

Use of Secrets File: Secret in "Ansible Public Service Config"
- ansible-vault create secrets.yaml
- ansible-vault decrypt secrets.yaml
- ansible-vault encrypt secrets.yaml
- Source: https://blog.ktz.me/secret-management-with-docker-compose-and-ansible/
