{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action":[
                "ec2:DescribeAddresses",
                "ec2:DescribeInstances",
                "ec2:AssociateAddress",
                "ec2:DisassociateAddress",
                "tag:GetTagValues"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
