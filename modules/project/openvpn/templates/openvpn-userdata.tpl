#cloud-config
repo_update: true
repo_upgrade: all

runcmd:
- aws ec2 --region ${region} modify-instance-attribute --instance-id $(curl 169.254.169.254/latest/meta-data/instance-id) --no-source-dest-check
- aws ec2 --region ${region} assign-private-ip-addresses --network-interface-id $(aws ec2 --region=${region} describe-network-interfaces --filters Name=attachment.instance-id,Values=$(curl 169.254.169.254/latest/meta-data/instance-id) --query NetworkInterfaces[0].NetworkInterfaceId --output text) --no-allow-reassignment --private-ip-addresses ${openvpn_secondary_private_ip}
- yum -y install ncurses-compat-libs
- yum -y install https://as-repository.openvpn.net/as-repo-centos7.rpm
- yum -y install openvpn-as
- aws s3 sync s3://${openvpn_backup_bucket}/etc /usr/local/openvpn_as/etc/ --exclude "*" --include "as.conf" --include "db/*"
- /usr/local/openvpn_as/scripts/ovpnpasswd -u openvpn -p $(aws ssm --region=${region} get-parameter --name ${openvpn-master-password-parameter} --with-decryption --output text --query 'Parameter.Value')
- (crontab -l ; echo "*/5 * * * * aws s3 sync /usr/local/openvpn_as/etc/ s3://${openvpn_backup_bucket}/etc --exclude \"*\" --include \"/usr/local/openvpn_as/etc/as.conf\" --include \"/usr/local/openvpn_as/etc/db/*\"")| crontab -
- aws ec2 --region ${region} delete-route --route-table-id ${private-route_table} --destination-cidr-block ${openvpn_network}
- aws ec2 --region ${region} delete-route --route-table-id ${public-route_table} --destination-cidr-block ${openvpn_network}
- aws ec2 --region ${region} create-route --route-table-id ${private-route_table} --destination-cidr-block ${openvpn_network} --instance-id $(curl 169.254.169.254/latest/meta-data/instance-id)
- aws ec2 --region ${region} create-route --route-table-id ${public-route_table} --destination-cidr-block ${openvpn_network} --instance-id $(curl 169.254.169.254/latest/meta-data/instance-id)
- service network restart
- service openvpnas restart