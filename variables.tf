variable "vpc_cidr" {
  type        = string
  description = "The CIDR to use for the VPC."
}
variable "region" {
  type        = string
  description = "The region into which to deploy the VPC."
}
variable "availability_zones" {
  type        = list(string)
  description = "The availability zones for which to add subnets."
}

variable "component" {
  type        = string
  description = "The component this network will contain."
}
variable "deployment_identifier" {
  type        = string
  description = "An identifier for this instantiation."
}
variable "dependencies" {
  description = "A comma separated list of components depended on my this component."
  type        = list(string)
  default     = []
}

variable "public_subnets_offset" {
  description = "The number of /24s to offset the public subnets in the VPC CIDR."
  type        = number
  default     = 0
}
variable "private_subnets_offset" {
  description = "The number of /24s to offset the private subnets in the VPC CIDR."
  type        = number
  default     = 0
}

variable "include_route53_zone_association" {
  description = "Whether or not to associate the VPC with a zone id."
  type        = string
  default     = "yes"
}

variable "private_zone_id" {
  description = "The ID of the private Route 53 zone."
  type        = string
  default     = ""
}

variable "include_nat_gateway" {
  description = "Whether or not to deploy a NAT gateway for outbound Internet connectivity."
  type        = string
  default     = "yes"
}

variable "include_lifecycle_events" {
  description = "Whether or not to notify via S3 of a created VPC."
  type        = string
  default     = "yes"
}
variable "infrastructure_events_bucket" {
  description = "S3 bucket in which to put VPC creation events. Required when `include_lifecycle_events` is 'yes'."
  type        = string
  default     = ""
}

variable "secondary_subnets" {
  type    = list(string)
  default = []
}
