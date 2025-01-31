[kafka_node_ips]
${kafka_public_ip} ansible_user=ubuntu
[crdb_node_ips]
${crdb_public_ips} ansible_user=${ssh_user}
[crdb_node_ips_0]
${crdb_public_ips_0} ansible_user=${ssh_user}
[haproxy_node_ips]
${haproxy_public_ip} ansible_user=${ssh_user}
[app_node_ips]
${app_public_ips} ansible_user=${ssh_user}
[all_public_node_ips]
${all_public_ips} ansible_user=${ssh_user}
[all:vars]
ansible_connection=ssh
