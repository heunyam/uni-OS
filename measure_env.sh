# Environment

# data: CPU processor
# source: nproc
echo "cpu=$(nproc)"

# data: PHP-FPM process
# source: pgrep -u apache -c php-fpm
echo "fpm_total=$(pgrep -c php-fpm)"
echo "fpm_worker=$(pgrep -u apache -c php-fpm)"
