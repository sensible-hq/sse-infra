# Sensible

```
terraform init -backend-config=config/dev/config.remote
terraform init -backend-config=config/snapsoft-test/config.remote
```

```
terraform apply -var-file=config/dev/config.tfvars
terraform apply -var-file=config/snapsoft-test/config.tfvars
```

```
terraform destroy -var-file=config/dev/config.tfvars
terraform destroy -var-file=config/snapsoft-test/config.tfvars
```
