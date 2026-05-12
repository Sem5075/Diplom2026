# Настройка платформы для развертывания web приложений с внедрением DevSecOps-практик
## Архитектура стенда

```
┌────────────────────────────────────────────────────────────┐
│                        Инфраструктура                      │
│                                                            │
│  ┌──────────────┐   ┌──────────────┐   ┌────────────────┐  │
│  │  Физ. сервер │   │ Физ. сервер  │   │    Proxmox     │  │
│  │    GitLab    │   │   Toolbox    │   │                │  │
│  │              │   │              │   │                │  │
│  │              │   │  Terraform   │   │  ┌──────────┐  │  │
│  │  GitLab CE   │   │  Ansible     │   │  │ master-1 │  │  │
│  │  Registry    │   │  kubectl     │   │  ├──────────┤  │  │
│  └──────────────┘   │  Helm        │   │  │ worker-1 │  │  │
│                     └──────────────┘   │  ├──────────┤  │  │
│                                        │  │ worker-2 │  │  │
│                                        │  ├──────────┤  │  │
│                                        │  │  Runner  │  │  │
│                                        │  └──────────┘  │  │
│                                        └────────────────┘  │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline WIP                    │
│                                                            │
│  GitLab CI  ──►  Build (Buildah)  ──►  Scan (Trivy)        │
│      │                                      │              │
│      ▼                                      ▼              │
│  Pre-commit                         ArgoCD (GitOps)        │
│  (detect-secrets,                        │                 │
│   hadolint)                              ▼                 │
│                                    Kubernetes Cluster      │
│                                          │                 │
│                                          ▼                 │
│                                    DAST (OWASP ZAP)        │
└────────────────────────────────────────────────────────────┘

```
## Структура репозитория
```
├── argo                  
│   ├── argo-cd-9.5.5.tgz                  # ArgoCD для локальной уставки (на случай timeout при обычной установке)
│   ├── argocd-apps.tf                     # Инфраструтурные приложения в кластер
│   ├── argocd.tf                          # ArgoCD через terraform
│   ├── argocd-values.yaml
│   ├── provider.tf
│   └── variables.tf            
├── gitlab
│   ├── ansible
│   │   ├── ansible.cfg
│   │   ├── inventory
│   │   │   └── hosts.ini.template        # Шаблон для сервера Gitlab
│   │   ├── README.md                     # Информация о роли
│   │   ├── roles
│   │   │   └── gitlab
│   │   │       ├── defaults
│   │   │       │   └── main.yml
│   │   │       ├── handlers
│   │   │       │   └── main.yml
│   │   │       ├── tasks
│   │   │       │   ├── backup.yml
│   │   │       │   ├── deploy.yml
│   │   │       │   ├── directories.yml
│   │   │       │   ├── docker.yml
│   │   │       │   ├── main.yml
│   │   │       │   └── prerequisites.yml
│   │   │       └── templates
│   │   │           ├── docker-compose.yml.j2
│   │   │           ├── gitlab-backup.sh.j2
│   │   │           ├── gitlab.env.j2
│   │   │           └── gitlab-restore.sh.j2
│   │   ├── site.yml
│   │   ├── start.sh
│   │   └── stop.sh
│   ├── proxmox-runner.sh
│   └── terraform
│       ├── credentials.auto.tfvars.template
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       └── variables.tf
├── infra
│   ├── apps
│   │   ├── argocd-httproute.yaml
│   │   └── testapp-httproute.yaml
│   ├── envoy-gateway
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── gatewayclass.yaml
│   │   │   └── gateway.yaml
│   │   └── values.yaml
│   └── metallb
│       ├── Chart.yaml
│       ├── templates
│       │   ├── ipaddresspool.yaml
│       │   └── l2advertisement.yaml
│       └── values.yaml
└── kuber
    ├── configcopy.sh                   # Скрипт копирования kubeconfig после kubespray
    ├── inventory                        
    │   └── mycluster
    │       ├── group_vars
    │       │   └── all
    │       │       └── custom-dns.yml  # Настройки DNS для кластера
    │       ├── hosts.yaml              # инвентарь для kubespray (появляеться после terraform)
    │       └── vm_ids.env              # id и имена созданных terraform ВМ (появляеться после terraform, используется скриптами)
    ├── kubeconfig                      
    │   └── admin.conf                  # Скопированный kubeconfig (появляеться после kubespray и configcopy)
    ├── kubespray.sh                    # Скрипт запуска kubespray в docker для деплоя кластера
    ├── proxmox-vms.sh                  # Скрипт управления ВМ на Proxmox (читает inventory/mycluster/hosts.yaml)
    └── terraform                       # Создание ВМ для кластера Kubernetes через terraform
        ├── credentials.auto.tfvars.template
        ├── inventory.tpl               # Шаблон для Kubespray
        ├── main.tf
        ├── outputs.tf
        ├── provider.tf
        └── variables.tf                # Переменные для ВМ
  ``` 
