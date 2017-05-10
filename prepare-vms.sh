gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-f

gcloud compute networks create openebs-net  --mode custom
gcloud compute networks subnets create openebs-subnet \
  --network openebs-net \
  --range 10.240.0.0/24 \
  --region us-central1

gcloud compute firewall-rules create openebs-allow-internal \
  --allow tcp,udp,icmp \
  --network openebs-net \
  --source-ranges 10.240.0.0/24
gcloud compute firewall-rules create openebs-allow-external \
  --allow tcp:22,icmp \
  --network openebs-net \
  --source-ranges 0.0.0.0/0
gcloud compute firewall-rules list --filter "network=openebs-net"

gcloud compute instances create kubemaster-01 \
 --boot-disk-size 20GB \
 --can-ip-forward \
 --image ubuntu-1604-xenial-v20170307 \
 --image-project ubuntu-os-cloud \
 --machine-type n1-standard-2 \
 --private-network-ip 10.240.0.10 \
 --subnet openebs-subnet

gcloud compute instances create kubeminion-01 \
 --boot-disk-size 20GB \
 --can-ip-forward \
 --image ubuntu-1604-xenial-v20170307 \
 --image-project ubuntu-os-cloud \
 --machine-type n1-standard-2 \
 --private-network-ip 10.240.0.20 \
 --subnet openebs-subnet

gcloud compute instances create omm-01 \
 --boot-disk-size 20GB \
 --can-ip-forward \
 --image ubuntu-1604-xenial-v20170307 \
 --image-project ubuntu-os-cloud \
 --machine-type n1-standard-2 \
 --private-network-ip 10.240.0.30 \
 --subnet openebs-subnet

gcloud compute instances create osh-01 \
 --boot-disk-size 20GB \
 --can-ip-forward \
 --image ubuntu-1604-xenial-v20170307 \
 --image-project ubuntu-os-cloud \
 --machine-type n1-standard-2 \
 --private-network-ip 10.240.0.40 \
 --subnet openebs-subnet

