resource "aws_instance" "app" {
  count                       = var.include_app == "yes" && var.create_ec2_instances == "yes" ? 1 : 0
  tags                        = merge(local.tags, {Name = "${var.owner}-crdb-app-${count.index}"})
  ami                         = "${data.aws_ami.amazon_linux_2023_x64.id}"
  instance_type               = var.app_instance_type
  key_name                    = var.crdb_instance_key_name
  iam_instance_profile  = var.enable_s3_iam ? aws_iam_instance_profile.ec2_instance_profile[0].name : null

  network_interface {
    network_interface_id = aws_network_interface.app[count.index].id
    device_index = 0
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 100
  }
  #  To connect using the keys that have been created:
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"  # Change to "required" only if your application supports IMDSv2 token retrieval
  }
}
