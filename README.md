# platform-infra

Infrastructure as Code (Terraform) de la plateforme. Responsable : P3.

```
bootstrap/       à lancer une fois à la main : bucket S3 + table de verrou pour le state
modules/vpc/     réseau (sous-réseaux publics et privés, NAT)
modules/eks/     cluster EKS et groupe de nœuds
envs/dev/        environnement dev (staging et prod à copier depuis dev)
```

## Ordre d'exécution

```bash
# 1. State Terraform (une seule fois)
cd bootstrap
terraform init
terraform apply -var state_bucket_name=plateforme-tfstate-<identifiant-unique>

# 2. Reporter bucket et table dans envs/dev/main.tf (bloc backend), puis :
cd ../envs/dev
terraform init
terraform plan -var github_org=<votre-organisation>
terraform apply -var github_org=<votre-organisation>
```

Après l'`apply`, copier la sortie `github_ci_role_arn` dans le secret GitHub `AWS_ROLE_ARN` de `sample-api`.
Vérifier la version Kubernetes (variable `cluster_version`) avant la première création.

## Coûts

Le cluster EKS (environ 0,10 $/h) et la NAT Gateway coûtent même sans trafic.
Faire `terraform destroy` sur `envs/dev` à la fin de chaque journée de travail.
