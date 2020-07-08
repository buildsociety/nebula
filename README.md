# nebula

Contains the command-line client for Nebula, a scalable overlay networking tool with a focus on performance, simplicity and security. Built from source nightly against their latest release.

## Getting started

```bash
    docker pull buildsociety/nebula:latest
    docker run -td --cap-add NET_ADMIN -v /path/to/config:/config buildsociety/nebula:latest
```

User documentation for Nebula can be found at https://github.com/slackhq/nebula#readme

## Kubernetes Sidecar

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ...
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ...
  template:
    metadata:
      labels:
        app: ...
    spec:
      containers:
      - name: ...
      - name: nebula
        image: <nebula image>
        securityContext:
          capabilities:
            add:
              - NET_ADMIN
        volumeMounts:
        - mountPath: /config/config.yaml
          readOnly: true
          name: nebula-conf
        args: ["-config", "/config/config.yaml" ] 
      volumes:
      - name: nebula-conf
        configMap:
          name: nebula-conf
          items:
            - key: nebula.conf
              path: nebula.conf
```

## Licence

By using this image, you agree to the Nebula [licence](https://github.com/slackhq/nebula/blob/master/LICENSE)