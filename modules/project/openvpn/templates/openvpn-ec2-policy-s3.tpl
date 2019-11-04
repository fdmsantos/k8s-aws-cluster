{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "s3:ListBucket",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${openvpn_backup_bucket}"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${openvpn_backup_bucket}/*"
        }
    ]
}