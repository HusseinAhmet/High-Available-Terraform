output "vpc-id" {
  value = aws_vpc.VPC.id
}
output "Publicsubnet1_id" {
  value = aws_subnet.PubSub1.id
}
output "Publicsubnet2_id" {
  value = aws_subnet.PubSub2.id
}
output "Privsubnet1_id" {
  value = aws_subnet.PrivSub1.id
}
output "Privsubnet2_id" {
  value = aws_subnet.PrivSub2.id
}
