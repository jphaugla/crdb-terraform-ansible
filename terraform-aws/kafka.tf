# kafka Node
resource "aws_instance" "kafka" {
  # count         = 0
  count         = var.include_kafka == "yes" && var.create_ec2_instances == "yes" ? 1 : 0
  tags          = merge(local.tags, {Name = "${var.owner}-crdb-kafka-${count.index}"})
  ami           = "${data.aws_ami.amazon_linux_2023_x64.id}"
  instance_type = var.kafka_instance_type
  key_name      = var.crdb_instance_key_name
  network_interface {
    network_interface_id = aws_network_interface.kafka[count.index].id
    device_index = 0
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp2"
    volume_size           = 8
  }
}
