# resource "kubernetes_namespace" "eks_namespace" {
#   provider = kubernetes
#   count    = length(var.namespaces)
#
#   metadata {
#     annotations = {
#       name = element(var.namespaces, count.index)
#     }
#
#     labels = {
#       mylabel = element(var.namespaces, count.index)
#     }
#
#     name = element(var.namespaces, count.index)
#   }
# }
