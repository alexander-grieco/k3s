BASE_DIR=base
RELEASE_NAME=argocd
CHART_NAME=argo/argo-cd
VERSION=7.6.8

.PHONY: install-dependencies
install-dependencies:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update

.PHONY: template
template: install-dependencies
	rm -rf ${BASE_DIR}/${RELEASE_NAME}
	helm template --create-namespace -n argocd ${RELEASE_NAME} $(CHART_NAME) --version $(VERSION) -f ./values.yaml
	kustomize build .

.PHONY: deploy
deploy: install-dependencies
	helm upgrade --install --create-namespace --wait -n argocd $(RELEASE_NAME) $(CHART_NAME) --version $(VERSION) -f ./values.yaml
	kubectl -n argocd apply -k .
