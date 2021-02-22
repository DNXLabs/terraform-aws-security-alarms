# terraform-aws-security-alarms

[![Lint Status](https://github.com/DNXLabs/terraform-aws-security-alarms/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-security-alarms/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-security-alarms)](https://github.com/DNXLabs/terraform-aws-security-alarms/blob/master/LICENSE)


<!--- BEGIN_TF_DOCS --->

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alarm\_account\_ids | AWS Account IDs to allow receiving alarms to the SNS Topic | `list` | `[]` | no |
| alarm\_namespace | The namespace in which all alarms are set up. | `string` | `"CISBenchmark"` | no |
| alarm\_sns\_topic\_name | The name of the SNS Topic which will be notified when any alarm is performed. | `string` | `"CISAlarm"` | no |
| cloudtrail\_log\_group\_name | The name of Cloudtrail log group. (Default is <org-name>-cloudtrail) | `string` | `""` | no |
| enable\_alarm\_baseline | The boolean flag whether this module is enabled or not. No resources are created when set to false. | `bool` | `true` | no |
| enable\_chatbot\_slack | If true, will create aws chatboot and integrate to slack | `bool` | `true` | no |
| org\_name | Name for this organization | `any` | n/a | yes |
| slack\_channel\_id | Slack channel id to send budget notification using AWS Chatbot | `string` | `""` | no |
| slack\_workspace\_id | Slack workspace id to send budget notification using AWS Chatbot | `string` | `""` | no |
| tags | Specifies object tags key and value. This applies to all resources created by this module. | `map` | <pre>{<br>  "Terraform": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| alarm\_sns\_topic | The SNS topic to which CloudWatch Alarms will be sent. |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-security-alarms/blob/master/LICENSE) for full details.
