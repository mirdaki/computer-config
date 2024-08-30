# Local Service Setup

Here are manual steps I did to set this up

0. Setup Docker
1. Created `sudo mkdir /services/*`
2. Make a folder for each service being added and copy over the docker-compose
3. Gave my users access:
    - Switch the group `sudo chgrp <name> /services/*`
    - Add read write permissions for group `sudo chmod -R 0773 /services/*`
    - Investigate making a service group or something
4. Create a docker network `sudo docker network create lan`
5. Configure domain names
    - Either use `/etc/hosts` to point compose host names to the IP address
    - Add a `custom.list` to the Pi-Hole with the pairings. Remember clients must get their DHCP from the Pi-Hole before this will work

TODO: This needs some rethinking, hard to edit
