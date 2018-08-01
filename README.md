# Setting up Help Users Vote on Google Cloud

## Terraform

- Configure Terraform for Google Cloud Provider using [these](https://www.terraform.io/docs/providers/google/index.html) instructions. This should look like this if using fixed credentials:
**main.tf**
```hcl
provider "google" {
  credentials = "${file("MyGcloudProject-a1234567abcd.json")}"
}
```

- Setup Google provider with `terraform init`.

- Deploy Kubernetes cluster running Help Users Vote with `terraform apply`.
