# GitHub Actions 上でキャッシュを行うためのビルド差分設定

target "dev-image" {
  cache-from = [
    "type=gha,scope=dev"
  ]
  cache-to = [
    "type=gha,scope=dev,mode=max"
  ]
}

target "prod-image" {
  cache-from = [
    "type=gha,scope=prod"
  ]
  cache-to = [
    "type=gha,scope=prod,mode=max"
  ]
}
