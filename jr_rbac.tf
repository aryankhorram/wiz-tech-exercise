# 1) Create a ServiceAccount (an identity for the app pod)
resource "kubernetes_service_account" "jr_admin_sa" {
  metadata {
    name      = "jr-tasky-admin-sa"
    namespace = kubernetes_namespace.jr_app_ns.metadata[0].name
  }
}

# 2) Bind that ServiceAccount to the built-in cluster-admin role (cluster-wide admin)
resource "kubernetes_cluster_role_binding" "jr_admin_bind" {
  metadata {
    name = "jr-tasky-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jr_admin_sa.metadata[0].name
    namespace = kubernetes_namespace.jr_app_ns.metadata[0].name
  }
}