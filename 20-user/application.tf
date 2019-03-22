data "aws_iam_group" "this" {
  group_name = "Application"
}

resource "aws_iam_user" "this" {
  name = "${var.project}"
  path = "/"
}

resource "aws_iam_user_group_membership" "this" {
  user = "${aws_iam_user.this.name}"

  groups = [
    "${data.aws_iam_group.this.group_name}",
  ]
}

resource "aws_iam_access_key" "access_key" {
  user = "${var.project}"

  depends_on = [
    "aws_iam_user.this",
  ]
}

output "application_user_access_key" {
  value = "${aws_iam_access_key.access_key.id}"
}

output "application_user_access_key_secret" {
  value = "${aws_iam_access_key.access_key.secret}"
}
