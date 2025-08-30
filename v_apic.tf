
variable "apic" {
  description = "Login information"
  type        = map(any)
  default = {
    url      = "https://apicsim.ntt.lab"
    username = "admin"
    password = "simulator"
  }
}

#variable "username" {
# type        = string
#  validation {
#   condition     = length(var.password) > 0
#   error_message = "Cannot be empty"
# }
#}

#variable "password" {
# type        = string
# sensitive   = true
#  validation {
#   condition     = length(var.password) > 0
#   error_message = "Cannot be empty"
# }
#}
