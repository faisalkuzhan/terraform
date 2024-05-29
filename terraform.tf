    provider "aws" {
    region = "us-east-1" # Specify your desired region
    }

    # Create an S3 Bucket
    resource "aws_s3_bucket" "fazlis3bucket3846" {
    bucket = "example-bucket"
    acl    = "private"
    }

    # Create a KMS Key
    resource "aws_kms_key" "example" {
    description             = "Example KMS Key"
    deletion_window_in_days = 10
    }

    # Create an IAM Role
    resource "aws_iam_role" "example" {
    name = "example-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        }]
    })
    }

    # Create a Sample IAM Policy and attach to the IAM Role
    resource "aws_iam_policy" "example_policy" {
    name        = "example-policy"
    description = "A sample policy"
    policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action = [
            "s3:ListBucket",
            "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "*"
        }]
    })
    }

    resource "aws_iam_role_policy_attachment" "example_attach" {
    role       = aws_iam_role.example.name
    policy_arn = aws_iam_policy.example_policy.arn
    }

    # Create a Security Group with Port 3306 open for 0.0.0.0/0
    resource "aws_security_group" "example" {
    vpc_id = "vpc-02268424c2b6f0369" 

    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "example-security-group"
    }
    }

    # Create an RDS Instance with MySQL
    resource "aws_db_instance" "example" {
    allocated_storage    = 20
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t2.micro"
    username             = "exampleuser"
    password             = "examplepassword"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true

    vpc_security_group_ids = [aws_security_group.example.id]

    tags = {
        Name = "example-rds"
    }
    }

    # Create an AWS Glue Job
    resource "aws_glue_job" "example" {
    name     = "example-glue-job"
    role_arn = aws_iam_role.example.arn

    command {
        name            = "glueetl"
        script_location = "s3://example-bucket/scripts/example-script.py"
        python_version  = "3"
    }

    default_arguments = {
        "--job-language" = "python"
    }

    max_retries = 1
    timeout     = 2880
    }

    # Create an Application Load Balancer
    resource "aws_lb" "example" {
    name               = "example-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.example.id]
    subnets            = ["subnet-014167b94706543df", "subnet-0bfad4f707f61dc5a"] 

    enable_deletion_protection = false

    tags = {
        Name = "example-alb"
    }
    }

    # Create an AutoScaling Group
    resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.id
    min_size             = 1
    max_size             = 3
    desired_capacity     = 1
    vpc_zone_identifier  = ["subnet-0f23c5ceee52bd56e", "subnet-0f7fb18d2795c811c"] 

    tag {
        key                 = "Name"
        value               = "example-asg"
        propagate_at_launch = true
    }
    }

    # Create a Launch Configuration for AutoScaling Group
    resource "aws_launch_configuration" "example" {
    name          = "example-launch-configuration"
    image_id      = "ami-00beae93a2d981137" 
    instance_type = "t2.micro"
    security_groups = [aws_security_group.example.id]

    lifecycle {
        create_before_destroy = true
    }
    }

