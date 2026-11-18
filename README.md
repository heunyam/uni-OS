# Simple Setup Guide

Prerequisite: Linux Environment Setup Guide (Apache, PHP-FPM, MariaDB, WordPress)

## 1. Port Forwarding (UTM GUI, NAT)

```bash
# Host 2222 -> Guest 22 (SSH), Host 8080 -> Guest 80 (Web)
ssh -p 2222 ksj@localhost                                                    # check SSH
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/wordpress/    # check Web (200)
```

## 2. VM Setup (run on VM)

```bash
sudo dnf install sysstat -y
sudo sed -i "1a define( 'WP_ENVIRONMENT_TYPE', 'local' );" /var/www/html/wordpress/wp-config.php
grep WP_ENVIRONMENT_TYPE /var/www/html/wordpress/wp-config.php               # check
```

## 3. Application Password (wp-admin GUI)

```bash
# admin user > Profile > Application Passwords > Add New
curl -s -u "admin:<application password>" "http://localhost:8080/wordpress/?rest_route=/wp/v2/users/me"   # check
```

## 4. .env (Mac, src/)

```bash
cat > .env <<'EOF'
HOST="ksj@localhost"
SSH_PORT=2222
HTTP_PORT=8080
URL="http://localhost:${HTTP_PORT}/wordpress/?rest_route=/wp/v2/posts"
AUTH="admin:<application password>"
DURATION=20
EOF
```

## 5. Run (Mac, src/)

```bash
bash intervention.sh 12 && bash main.sh   # Reproduction
bash intervention.sh 2  && bash main.sh   # Intervention
bash intervention.sh 12                   # restore
```
