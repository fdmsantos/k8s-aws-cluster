{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeNetworkInterfaces",
                "ec2:ModifyInstanceAttribute",
                "ec2:AssignPrivateIpAddresses"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}