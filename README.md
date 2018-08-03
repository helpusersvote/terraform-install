# Running Help Users Vote on Kubernetes using Terraform

## Deploy
Currently, only Google Kubernetes Engine (GKE) is supported but other providers are planned in the future.

### Google

- Configure Terraform for Google Cloud Provider using [these](https://www.terraform.io/docs/providers/google/index.html) instructions. This should look like this if using fixed credentials:
**main.tf**
```hcl
provider "google" {
  credentials = "${file("MyGcloudProject-a1234567abcd.json")}"
}
```
- Follow generic instructions to complete.

### Generic

- Setup providers with `terraform init`.

- Deploy Kubernetes cluster running Help Users Vote with `terraform apply`.

## Development
- Contributions should be formatted with [hclfmt](https://github.com/fatih/hclfmt). Run `./hack/setup-githooks.sh` to check pre-commit.
