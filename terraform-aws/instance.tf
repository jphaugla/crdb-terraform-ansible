# CRDB Nodes
resource "aws_instance" "crdb" {
  count         = var.create_ec2_instances == "yes" ? var.crdb_nodes : 0
  tags = merge(local.tags, {Name = "${var.owner}-crdb-instance-${count.index}"})
  ami           = local.ami_id
  instance_type = var.crdb_instance_type
  network_interface {
    # network_interface_id = data.aws_network_interface.details[count.index].id
    network_interface_id = aws_network_interface.crdb[count.index].id
    device_index = 0
  }
  key_name      = var.crdb_instance_key_name
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_type = var.crdb_root_volume_type
    volume_size = var.crdb_root_volume_size
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    delete_on_termination = true
    encrypted = true
    volume_type = var.crdb_store_volume_type
    volume_size = var.crdb_store_volume_size
  }
}
