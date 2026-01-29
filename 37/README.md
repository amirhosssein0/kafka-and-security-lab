Ingress TLS with Self-Signed Certificate

1) Generate the Self‑Signed Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=random.app.local" \
  -addext "subjectAltName = DNS:random.app.local,DNS:spacex.app.local"

2) kubectl create secret tls tls-secret --key=tls.key --cert=tls.crt

3) kubectl apply -f ./ingress.yaml -f ./spacex/ -f ./random/
