set -xe
gcloud -q compute instances delete \
    kubemaster-01 kubeminion-01 omm-01 osh-01

gcloud -q compute firewall-rules delete \
    openebs-allow-internal \
    openebs-allow-external

gcloud -q compute networks subnets delete openebs-subnet
gcloud -q compute networks delete openebs-net

