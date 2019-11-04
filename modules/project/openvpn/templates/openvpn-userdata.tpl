yum -y update
yum -y install ncurses-compat-libs
yum -y install https://as-repository.openvpn.net/as-repo-centos7.rpm
yum -y install openvpn-as
# passwd openvpn
# Por Password

# aws s3 sync . s3://fsantos-openvpn-server-backup/etc --exclude "*" --include "as.conf" --include "db/*"