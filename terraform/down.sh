# Bring down all the created infra through terraform on all clouds
echo "---------------------------------------------------"
echo "Destroying AWS infra"
echo "---------------------------------------------------"
cd ./aws
terraform destroy -auto-approve
echo "---------------------------------------------------"
echo "Destroying GCP infra"
echo "---------------------------------------------------"
cd ../gcp
terraform destroy -auto-approve
echo "---------------------------------------------------"
echo "Destroying Azure infra"
echo "---------------------------------------------------"
cd ../azure
terraform destroy -auto-approve
cd ../
echo "---------------------------------------------------"
echo "Destruction complete"
echo "---------------------------------------------------"
