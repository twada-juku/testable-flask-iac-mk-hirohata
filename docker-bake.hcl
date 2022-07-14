# docker-bake.hcl
# buildx で使用するビルド定義

# デフォルトで並列ビルドするtarget
group "default" {
  targets = ["dev-image", "prod-image"]
  # targets = ["dev-image", "prod-image", "iac-image"]
}

# 開発環境用イメージビルド定義
target "dev-image" {
  dockerfile = "Dockerfile"
  # 紛らわしいがこちらは Dockerfile の中の stage を指す
  target = "dev"
  # できあがったイメージにつけるタグ名
  tags = [
    "testable-flask-iac_stage-dev"
  ]
}

# 本番環境用イメージビルド定義
target "prod-image" {
  dockerfile = "Dockerfile"
  # 紛らわしいがこちらは Dockerfile の中の stage を指す
  target = "prod"
  # できあがったイメージにつけるタグ名
  tags = [
    "testable-flask-iac_stage-prod"
  ]
}

# インフラ定義用イメージビルド定義
target "iac-image" {
  dockerfile = "iac/Dockerfile"
  tags = [
    "testable-flask-iac_iac"
  ]
}
