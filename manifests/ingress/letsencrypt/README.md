# To create the tls certificate do the following steps:
# Make sure the domain is valid and assigned to your nginx via dns

# For a non-wildcard cert:
# This Setup is typically via ingress

    $ k apply -f cluster-issuer.yaml
    $ k apply -f certificate.yaml # should be in namespace

# For wild-card certs (my provider is gcp) do the following:

    $ gcloud iam service-accounts create cert-manager-dns   --display-name "cert-manager DNS01 solver"

    $ gcloud projects add-iam-policy-binding $project_id   --member "serviceAccount:cert-manager-dns@$project_id.iam.gserviceaccount.com"   --role "roles/dns.admin"

    $ gcloud iam service-accounts keys create ./gcp-dns-credentials.json   --iam-account cert-manager-dns@$project_id.iam.gserviceaccount.com

    $ k create secret generic gcp-dns-credentials \
      --from-file=key.json=./gcp-dns-credentials.json \
      --namespace cert-manager
    $ k apply -f wildcard-cluster-issuer.yaml
    $ k apply -f wildcard-cert-hquarter.yaml # should be in namespace
