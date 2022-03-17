Terraform AWS Base Networking
=============================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-base-networking.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-base-networking)

A Terraform module for building a base network in AWS.

The network consists of:

* Public and private subnets for each supplied availability zone
* A NAT gateway for each supplied availability zone for outbound Internet
  connectivity
* Routes from the public subnets to the Internet gateway
* Routes from the private subnets to the NAT
* Standard tags for all resources

![Diagram of infrastructure managed by this module](https://raw.githubusercontent.com/infrablocks/terraform-aws-base-networking/main/docs/architecture.png)

Usage
-----

To use the module, include something like the following in your terraform
configuration:

```hcl-terraform
module "base-network" {
  source  = "infrablocks/base-networking/aws"
  version = "4.0.0"

  vpc_cidr           = "10.0.0.0/16"
  region             = "eu-west-2"
  availability_zones = ["eu-west-2a", "eu-west-2b"]

  component             = "important-component"
  deployment_identifier = "production"

  private_zone_id = "Z3CVA9QD5NHSW3"
}
```

See the
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/base-networking/aws/latest)
for more details.

### Inputs

| Name                             | Description                                                                               | Default | Required                                     |
|----------------------------------|-------------------------------------------------------------------------------------------|:-------:|:--------------------------------------------:|
| vpc_cidr                         | The CIDR to use for the VPC                                                               | -       | yes                                          |
| region                           | The region into which to deploy the VPC                                                   | -       | yes                                          |
| availability_zones               | The availability zones for which to add subnets                                           | -       | yes                                          |
| public_subnets_offset            | The number of /24s to offset the public subnets in the VPC CIDR                           | 0       | yes                                          |
| private_subnets_offset           | The number of /24s to offset the private subnets in the VPC CIDR                          | 0       | yes                                          |
| component                        | The component this network will contain                                                   | -       | yes                                          |
| deployment_identifier            | An identifier for this instantiation                                                      | -       | yes                                          |
| dependencies                     | The components depended on by this component                                              | -       | no                                           |
| include_route53_zone_association | Whether or not to associate VPC with the private Route 53 zone ("yes" or "no")            | "yes"   | no                                           |
| private_zone_id                  | The ID of the private Route 53 zone                                                       | -       | if include_route53_zone_association is "yes" |
| include_nat_gateways             | Whether or not to deploy NAT gateways for outbound Internet connectivity ("yes" or "no")  | "yes"   | yes                                          |

### Outputs

| Name                         | Description                                          |
|------------------------------|------------------------------------------------------|
| vpc_id                       | The ID of the created VPC                            |
| vpc_cidr                     | The CIDR of the created VPC                          |
| availability_zones           | The availability zones in which subnets were created |
| number_of_availability_zones | The number of populated availability zones available |
| public_subnet_ids            | The IDs of the public subnets                        |
| public_subnet_cidrs          | The CIDRs of the public subnets                      |
| public_route_table_ids       | The IDs of the public route tables                   |
| private_subnet_ids           | The IDs of the private subnets                       |
| private_subnet_cidrs         | The CIDRs of the private subnets                     |
| private_route_table_ids      | The IDs of the private route tables                  |
| nat_public_ips               | The EIPs attached to the NAT gateways                |

### Compatibility

This module is compatible with Terraform versions greater than or equal to
Terraform 1.0.

### Required Permissions

* ec2:DescribeVpcs
* ec2:DescribeAddresses
* ec2:DescribeVpcAttribute
* ec2:DescribeVpcClassicLink
* ec2:DescribeVpcClassicLinkDnsSupport
* ec2:DescribeRouteTables
* ec2:DescribeSecurityGroups
* ec2:DescribeNetworkAcls
* ec2:DescribeSubnets
* ec2:DescribeInternetGateways
* ec2:DescribeNatGateways
* ec2:ModifyVpcAttribute
* ec2:AllocateAddress
* ec2:ReleaseAddress
* ec2:AssociateRouteTable
* ec2:DisassociateRouteTable
* ec2:AttachInternetGateway
* ec2:DetachInternetGateway
* ec2:DeleteInternetGateway
* ec2:CreateRoute
* ec2:CreateNatGateway
* ec2:CreateVpc
* ec2:CreateTags
* ec2:CreateSubnet
* ec2:CreateRouteTable
* ec2:CreateInternetGateway
* ec2:DeleteRoute
* ec2:DeleteRouteTable
* ec2:DeleteSubnet
* ec2:DeleteNatGateway
* ec2:DeleteVpc
* s3:ListBucket
* s3:GetObject
* s3:GetObjectTagging
* s3:DeleteObject
* route53:AssociateVPCWithHostedZone
* route53:DisassociateVPCFromHostedZone
* route53:GetChange
* route53:GetHostedZone

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed
on your development machine:

* Ruby (2.3.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 2.3.1
rbenv rehash
rbenv local 2.3.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

To provision module infrastructure, run tests and then destroy that
infrastructure, execute:

```bash
./go
```

To provision the module prerequisites:

```bash
./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```bash
./go deployment:harness:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
./go deployment:harness:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
./go deployment:prerequisites:destroy[<deployment_identifier>]
```

### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/infrablocks/terraform-aws-base-networking. This project is
intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


License
-------

The library is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
