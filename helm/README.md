  246  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  247  chmod 700 get_helm.sh
  248  ./get_helm.sh 
  249  helm
  250  helm repo add xrd https://ios-xr.github.io/xrd-helm
  253  rm get_helm.sh 
  289  helm install xrd xrd/xrd-vrouter
  291  helm install xrd xrd/xrd-vrouter -f values.yanml
  292  helm install xrd xrd/xrd-vrouter -f values.yaml
  304  helm list
  305  helm upgrade xrd -f values.yaml 
  306  helm upgrade xrd xrd/xrd-vrouter -f values.yaml 
  308  helm upgrade xrd xrd/xrd-vrouter -f values.yaml 
  310  helm upgrade xrd xrd/xrd-vrouter -f values.yaml 
  346  mkdir helm
  347  mv values.yaml helm/
  349  git commit -m "helm values"
  353  history | grep helm
  354  history | grep helm > helm/README.md
