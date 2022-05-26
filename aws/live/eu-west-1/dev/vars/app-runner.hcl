locals {
  httpbin_enabled_auto_deployments = true
  httpbin_image_version            = "v0.1.0"
  httpbin_port                     = 80

  httpbin_cpu    = 1024
  httpbin_memory = 2048

  httpbin_max_concurrency = 100
  httpbin_max_size        = 2
  httpbin_min_size        = 1
}
