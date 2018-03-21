output "master-public-ip" {
  value = "${aws_instance.master.public_ip}"
}

output "minion-public-ip" {
  value = "${aws_instance.minion.public_ip}"
}
