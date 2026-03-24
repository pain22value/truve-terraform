resource "aws_iam_policy" "alb_controller" {
  # name        = "${var.project_name}-${var.environment}-alb-controller-policy"
  name        = "truve-dev-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("alb-controller-iam-policy.json")
}

resource "aws_iam_role" "alb_controller_pod_identity" {
  name = "truve-dev-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEksPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller_pod_identity.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.alb_controller_pod_identity.arn
}
