resource "aws_quicksight_data_source" "athena" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_source_id = "quicksuite-athena"
  name           = "QuickSuite Analytics"
  type           = "ATHENA"

  parameters {
    athena {
      work_group = "primary"
    }
  }

  permission {
    actions = [
      "quicksight:DescribeDataSource",
      "quicksight:DescribeDataSourcePermissions",
      "quicksight:PassDataSource",
      "quicksight:UpdateDataSource",
      "quicksight:DeleteDataSource",
      "quicksight:UpdateDataSourcePermissions",
    ]
    principal = "arn:aws:quicksight:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:group/${var.quicksight_namespace}/${var.quicksight_admin_group}"
  }
}
