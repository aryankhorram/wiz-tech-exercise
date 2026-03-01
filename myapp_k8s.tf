resource "kubernetes_namespace" "jr_app_ns" {
  metadata {
    name = "jr-tasky"
  }
}

resource "kubernetes_deployment" "jr_tasky_deploy" {
  metadata {
    name      = "jr-tasky-app"
    namespace = kubernetes_namespace.jr_app_ns.metadata[0].name
    labels = {
      app = "jr-tasky"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jr-tasky"
      }
    }

    template {
      metadata {
        labels = {
          app = "jr-tasky"
        }
      }

      spec {
        container {
          name  = "jr-tasky-container"
          image = var.jr_tasky_image

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "jr_tasky_service" {
  metadata {
    name      = "jr-tasky-service"
    namespace = kubernetes_namespace.jr_app_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "jr-tasky"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}