gcloud compute copy-files scripts/setup_k8s_master.sh kubemaster-01:~/
gcloud compute copy-files scripts/setup_k8s_host.sh kubeminion-01:~/
gcloud compute copy-files scripts/setup_omm.sh omm-01:~/
gcloud compute copy-files scripts/setup_osh.sh osh-01:~/

gcloud compute ssh kubemaster-01 --command "chmod +x ~/setup_k8s_master.sh"
gcloud compute ssh kubeminion-01 --command "chmod +x ~/setup_k8s_host.sh"
gcloud compute ssh omm-01 --command "chmod +x ~/setup_omm.sh"
gcloud compute ssh osh-01 --command "chmod +x ~/setup_osh.sh"

