variable "name" {}
variable "resource_group" {}
variable "location" {}
variable "admin_username" {}
variable "admin_password" {}
variable "postgresql_version" {
  default = "13"
}
variable "sku_name" {
  default = "B_Standard_B1ms"
}
variable "storage_mb" {
  default = 32768
}
