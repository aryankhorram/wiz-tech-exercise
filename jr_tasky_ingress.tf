resource "kubernetes_ingress_v1" "jr_tasky_ing" {
  metadata {
    name      = "jr-tasky-ing"
    namespace = kubernetes_namespace.jr_app_ns.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.jr_tasky_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}