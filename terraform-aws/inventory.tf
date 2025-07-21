// terraform-aws/inventory.tf
resource "local_file" "instances_file" {
    filename = "${var.instances_inventory_file}"
    content = templatefile("${path.module}/${var.inventory_template_file}",
        {
            crdb_public_names = "${join("\n", (aws_instance.crdb.*.public_dns) )}"
            crdb_public_ips = "${join("\n", (aws_instance.crdb.*.public_ip) )}"
            crdb_public_ips_un = "${join("\n", [for ip in aws_instance.crdb.*.public_ip: "${ip} ansible_user=${local.admin_username}"])}"
            crdb_private_ips = "${join("\n", aws_instance.crdb[*].private_ip)}"
            crdb_private_ip_0 = "${aws_instance.crdb.0.private_ip}"
            crdb_public_ips_0 = "${aws_instance.crdb.0.public_ip}"
            kafka_public_ip = length(aws_instance.kafka) > 0 ? "${aws_instance.kafka.0.public_ip}" : "null"
            kafka_private_ip = length(aws_instance.kafka) > 0 ? "${aws_instance.kafka.0.private_ip}" : "null"
            haproxy_public_ip = "${aws_instance.haproxy.0.public_ip}"
            haproxy_private_ip = "${aws_instance.haproxy.0.private_ip}"
            app_public_ip = "${aws_instance.app.0.public_ip}"
            app_private_ip = "${aws_instance.app.0.private_ip}"
            app_private_ips = "${join("\n", aws_instance.app[*].private_ip)}"
            app_public_ips = "${join("\n", aws_instance.app[*].public_ip)}"
            app_public_ips_un = "${join("\n", [for ip in aws_instance.app.*.public_ip: "${ip} ansible_user=${local.admin_username}"])}"
            ssh_user = "${local.admin_username}"
            cluster_size = "${var.crdb_nodes}"
            all_public_ips_un = "${join("\n", flatten([
              [for ip in [aws_instance.haproxy.0.public_ip] : "${ip} ansible_user=${local.admin_username}"],
              [for ip in aws_instance.crdb.*.public_ip: "${ip} ansible_user=${local.admin_username}"],
              [for ip in aws_instance.app.*.public_ip: "${ip} ansible_user=${local.admin_username}"]
            ]))}"
            all_public_ips = "${join("\n", compact([
              aws_instance.haproxy.0.public_ip,
              join("\n", aws_instance.crdb.*.public_ip),
              join("\n", aws_instance.app.*.public_ip)
            ]))}"
        })

    depends_on = [
        aws_instance.crdb, aws_instance.kafka, aws_instance.app, aws_instance.haproxy
    ]
}
