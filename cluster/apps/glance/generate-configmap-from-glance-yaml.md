```bash
kubectl create configmap glance-config \
  --from-file=glance.yml=./glance.yml \
  --dry-run=client \
  -o yaml > glance-config.yaml
```
