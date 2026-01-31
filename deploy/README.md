# Env Set Up

### Bridge network for working ingress (for nodeports nat is sufficient)

## 1 HA Proxy

```bash
sudo zypper in haproxy
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy
```

## 2 Ingress controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm pull ingress-nginx/ingress-nginx --version 4.11.2

helm install ingress-nginx . -n ingress-nginx --create-namespace -f ingress_values.yaml
```

## 3 Demo app

```bash
kubectl apply -f test-ingress-app.yaml # simple demo app


# for debug
kubectl exec -it -n ingress-nginx ingress-nginx-controller-6c6d77bc8c-9f998 -- /bin/sh

kubectl run curl --rm -it --image=curlimages/curl -- sh
	cat /etc/resolv.conf
	nslookup kubernetes.default
	curl http://nginx-test.test-app.svc.cluster.local
```


# 4 Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm pull prometheus-community/kube-prometheus-stack --version 81.2.2

helm install monitoring . -n monitoring --create-namespace -f monitoring_values.yaml
```

### Resoult should be somthing like below

```
REVISION: 1
DESCRIPTION: Install complete
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=monitoring"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

