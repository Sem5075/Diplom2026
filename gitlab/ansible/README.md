# Ansible Role: GitLab (Docker Compose)

Роль для развёртывания GitLab CE/EE через Docker Compose с персистентными volumes.

## Структура проекта

```
ansible-gitlab/
├── ansible.cfg
├── site.yml                          # Основной playbook
├── inventory/
│   └── hosts.ini                     # Инвентарь (192.168.1.31)             
└── roles/gitlab/
    ├── defaults/main.yml             # Переменные по умолчанию
    ├── tasks/
    │   ├── main.yml                  # Точка входа
    │   ├── prerequisites.yml         # Установка зависимостей
    │   ├── docker.yml                # Установка Docker
    │   ├── directories.yml           # Создание директорий
    │   ├── deploy.yml                # Запуск GitLab
    │   └── backup.yml                # Настройка backup
    ├── templates/
    │   ├── docker-compose.yml.j2     # Docker Compose манифест
    │   ├── gitlab.env.j2             # Переменные окружения
    │   ├── gitlab-backup.sh.j2       # Скрипт резервного копирования
    │   └── gitlab-restore.sh.j2      # Скрипт восстановления
    └── handlers/main.yml             # Handlers (restart/reconfigure)
```

## Volumes (персистентные данные)

| Volume | Путь на хосте | Содержимое |
|--------|---------------|------------|
| `gitlab_config` | `/opt/gitlab/config` | gitlab.rb, секреты, SSL |
| `gitlab_logs` | `/opt/gitlab/logs` | Логи всех сервисов |
| `gitlab_data` | `/opt/gitlab/data` | Git репозитории, PostgreSQL, Redis, uploads |

## Быстрый старт

### 1. Требования

```bash
pip install ansible
ansible-galaxy collection install community.docker ansible.posix
```

### 2. Настройка инвентаря

```ini
[gitlab_servers]
gitlab ansible_host=192.168.1.31 ansible_user=user
```

### 3. Запуск

```bash
# Проверка доступности хоста
ansible all -m ping

# Тестовый прогон (без изменений)
ansible-playbook site.yml --check --diff --ask-become-pass

# Развёртывание
ansible-playbook site.yml --ask-become-pass
```

### 4. После развёртывания

```
URL:  http://192.168.1.31
SSH:  git@192.168.1.31 -p 2222
```

Начальный пароль root хранится в `/opt/gitlab/config/initial_root_password`
(удаляется автоматически через 24 часа).

## Основные переменные

| Переменная | По умолчанию | Описание |
|-----------|--------------|----------|
| `gitlab_version` | `latest` | Версия образа GitLab |
| `gitlab_external_url` | `http://192.168.1.31` | Внешний URL |
| `gitlab_http_port` | `80` | HTTP порт |
| `gitlab_ssh_port` | `2222` | SSH порт для git |
| `gitlab_base_dir` | `/opt/gitlab` | Базовая директория volumes |
| `gitlab_backup_enabled` | `true` | Включить автоматические backup-ы |
| `gitlab_backup_keep_time` | `604800` | Хранить backup 7 дней |

## Управление после развёртывания

```bash
cd /opt/gitlab

# Статус
docker compose ps

# Логи в реальном времени
docker compose logs -f --tail=100

# Перезапуск
docker compose restart

# Обновление GitLab
docker compose pull && docker compose up -d

# Ручной backup
/usr/local/bin/gitlab-backup.sh

# Восстановление
/usr/local/bin/gitlab-restore.sh <timestamp>
```

## HTTPS (опционально)

Для включения HTTPS измените в `defaults/main.yml`:

```yaml
gitlab_external_url: "https://192.168.1.31"
gitlab_http_port: 80
gitlab_https_port: 443
```

И поместите SSL сертификаты в `/opt/gitlab/config/ssl/`.

## Системные требования

- **RAM**: минимум 4GB (рекомендуется 8GB+)
- **CPU**: минимум 2 ядра
- **Диск**: минимум 20GB свободного места
- **OS**: Ubuntu 20.04+, Debian 11+, CentOS 8+, RHEL 8+
