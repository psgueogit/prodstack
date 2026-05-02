output "server_ip" {
  description = "Public IP of the k3s node"
  value       = hcloud_server.k3s_node.ipv4_address
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${hcloud_server.k3s_node.ipv4_address}"
}