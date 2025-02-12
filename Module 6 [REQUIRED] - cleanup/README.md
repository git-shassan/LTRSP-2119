```
cd ~/xrd-terraform
terraform -chdir=examples/cleu-topology/workload destroy -auto-approve
terraform -chdir=examples/cleu-topology/infra destroy -auto-approve
terraform -chdir=examples/bootstrap destroy -auto-approve
```
