locals {
  # Some AWS services are not available in every availability zone of a
  # region (for example, Transit Gateway attachments in eu-west-2d), so the
  # number of availability zones this module uses is capped.
  #
  # The cap is applied to the caller supplied list rather than replacing it,
  # so the ordering of the retained zones, and therefore the index of every
  # subnet and association, is unchanged.
  effective_availability_zones = slice(
    var.availability_zones,
    0,
    min(length(var.availability_zones), var.availability_zone_limit)
  )
}
