#!/bin/bash
ansible all -bK -m shell -a "docker compose -f /opt/gitlab/docker-compose.yml up -d"