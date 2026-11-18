
### Apache (Web Server)

0. install the httpd(Apache)
```shell
sudo dnf update -y
sudo dnf install httpd -y
httpd -v
```

1. enable auto-start
```
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd
```

2. Open firewall
```
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
sudo firewall-cmd --list-services
```

3. Port Forwarding
	Host: 127.0.0.1:8080
	Guest: -:80 
	
	Explain:
	QEMU -> Emulated VLAN -> Private IP address is allocated by DHCP
	so, guest(VM) IP should be empty or usually `10.0.2.15`


 4. Test
```
sudo vim /var/www/html/index.html
<h1/>Hello, World<h1>

curl http://localhost
```

5. Log
```
sudo tail -f /var/log/httpd/access_log
```

---

### MariaDB (Database Server)

0. install MariaDB
```shell
sudo dnf install mariadb-server -y
mariadb --version
```

1. enable auto-start
```shell
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb
```

2. Initial security setup
```shell
sudo mariadb-secure-installation
```
	Explain:
	set root password, remove anonymous users,
	disallow remote root login, remove test DB, reload privileges
	(older versions use `mysql_secure_installation`)

3. Login & create test DB / user
```shell
sudo mariadb -u root -p
```
```sql
CREATE DATABASE testdb;
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON testdb.* TO 'testuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

4. Test
```shell
mariadb -u testuser -p testdb -e "SELECT VERSION();"
sudo ss -tlnp | grep 3306
```
	Explain:
	MariaDB listens on TCP 3306

5. Log
```shell
sudo journalctl -u mariadb -f
sudo tail -f /var/log/mariadb/mariadb.log
```

---
### PHP + WordPress

0. Prerequisite check
```shell
sudo systemctl status httpd
sudo systemctl status mariadb
```

1. install PHP & modules
```shell
sudo dnf -y install php php-fpm php-mysqlnd php-opcache php-gd php-xml \
  php-mbstring php-json php-curl php-zip php-intl
```

2. enable php-fpm
```shell
sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl status php-fpm
sudo systemctl restart httpd
```
	Explain:
	php-fpm = separate process pool that runs PHP code
	Apache receives the request → hands .php files to php-fpm

3. Test PHP
```shell
sudo vim /var/www/html/info.php
```
```php
<?php phpinfo(); ?>
```
```shell
curl http://localhost/info.php
```
	From Mac: http://localhost:8080/info.php

4. Create WordPress DB
```shell
sudo mariadb -u root -p
```
```sql
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'Password123!';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

5. Download WordPress
```shell
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
ls -l          # → /var/www/html/wordpress
```

6. Permissions
```shell
sudo chown -R apache:apache /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
```

7. SELinux
```shell
sudo getenforce
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/wordpress(/.*)?"
sudo restorecon -Rv /var/www/html/wordpress
sudo setsebool -P httpd_can_network_connect_db on
ls -Zd /var/www/html/wordpress
```
	Explain:
	SELinux blocks Apache from writing files or connecting to DB by default,
	even if file permissions (chmod) allow it

8. Firewall
```shell
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

9. WordPress setup wizard (browser)
	URL: http://localhost:8080/wordpress
	DB Name: wordpress / User: wpuser / Password: Password123! / Host: localhost
	Then create admin account (separate from MariaDB account)
	Admin: http://localhost:8080/wordpress/wp-admin

10. Increase PHP limits
```shell
php --ini | grep "Loaded Configuration File"   # → /etc/php.ini
sudo touch /etc/php.ini

# change command
sudo sed -i -E 's/^;?\s*upload_max_filesize\s*=.*/upload_max_filesize = 64M/; s/^;?\s*post_max_size\s*=.*/post_max_size = 64M/; s/^;?\s*memory_limit\s*=.*/memory_limit = 256M/; s/^;?\s*max_execution_time\s*=.*/max_execution_time = 300/' /etc/php.ini

# check
grep -E '^(upload_max_filesize|post_max_size|memory_limit|max_execution_time)' /etc/php.ini
```
	upload_max_filesize = 64M
	post_max_size       = 64M
	memory_limit        = 256M
	max_execution_time  = 300
```shell
sudo systemctl restart php-fpm
sudo systemctl restart httpd
php -i | grep upload_max_filesize
```

11. Install FakerPress 0.72 plugin

```shell
cd /var/www/html/wordpress/wp-content/plugins
sudo wget https://downloads.wordpress.org/plugin/fakerpress.0.7.2.zip
sudo unzip fakerpress.0.7.2.zip
sudo chown -R apache:apache fakerpress
sudo restorecon -Rv fakerpress
sudo rm fakerpress.0.7.2.zip
```
	WP Admin → Plugins → Installed Plugins → Activate

12. Generate dummy data
	WP Admin → FakerPress
	Users 50 / Posts 500 / Terms 20 / Comments 1000
```sql
sudo mariadb -u root -p
USE wordpress;
SELECT COUNT(*) FROM wp_posts;
SELECT COUNT(*) FROM wp_comments;
SELECT COUNT(*) FROM wp_users;
```
