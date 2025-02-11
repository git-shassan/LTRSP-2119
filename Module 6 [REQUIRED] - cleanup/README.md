```
cd ~/xrd-terraform
terraform -auto-approve -chdir=examples/cleu-topology/workload destroy
terraform -auto-approve -chdir=examples/cleu-topology/infra destroy
terraform -auto-approve -chdir=examples/bootstrap destroy
```
