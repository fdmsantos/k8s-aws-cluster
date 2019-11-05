#cloud-config
repo_update: true
repo_upgrade: all

runcmd:
- yum -y install ncurses-compat-libs
- yum -y install https://as-repository.openvpn.net/as-repo-centos7.rpm
- yum -y install openvpn-as
- aws s3 sync s3://${openvpn_backup_bucket}/etc /usr/local/openvpn_as/etc/ --exclude "*" --include "as.conf" --include "db/*"
- /usr/local/openvpn_as/scripts/ovpnpasswd -u openvpn -p $(aws ssm --region=${region} get-parameter --name ${openvpn-master-password-parameter} --with-decryption --output text --query 'Parameter.Value')
- (crontab -l ; echo "*/5 * * * * aws s3 sync /usr/local/openvpn_as/etc/ s3://${openvpn_backup_bucket}/etc --exclude \"*\" --include \"/usr/local/openvpn_as/etc/as.conf\" --include \"/usr/local/openvpn_as/etc/db/*\"")| crontab -