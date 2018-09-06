# Running Help Users Vote on Kubernetes using Terraform

## Deploy
Currently, only Google Kubernetes Engine (GKE) is supported but other providers are planned in the future.

### Google

- [Create a Google Cloud project](https://console.cloud.google.com/projectcreate) for use by Help Users Vote. Note the project ID to be used by Terraform.

- A service account is needed to manage resources within the project. [Go to Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) and create a new Service Account used to administer the project with the following properties:
  * **Service account name**: `HelpUsersVoteAdmin` (can be changed)
  * **Project role:** Project -> Owner
  * **Furnish a new private key** is checked
  * Click "Save" and note the location that the key is downloaded to.

- Download and install Terraform and kubectl on your computer by running:
```bash
curl -L https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_$(uname | tr A-Z a-z)_amd64.zip | funzip >terraform
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.11.2/bin/$(uname | tr A-Z a-z)/amd64/kubectl
sudo install ./kubectl ./terraform /usr/local/bin
```

- Create a new directory for Terraform on your computer and enter it.
```bash
mkdir helpusersvote
cd helpusersvote
```

- Create a new file called `main.tf` in this new directory, substitute variables `gcloud_creds`, `cluster_password`, and `cluster_project` with appropriate values:
```hcl
module "huv-cluster" {
  source = "github.com/helpusersvote/terraform-kubernetes-helpusersvote"

  // change path inside of "file" to the path to the credentials downloaded above
  gcloud_creds = "${file("project-hash-qk9304fwe0.json")}"

  // choose a password for manual access to the cluster (must be 16 chars)
  cluster_password = "somesecurepasswordthathasntbeensharedbefore"

  // name of the project created above
  cluster_project = "myprojectname"
}
```

- Setup providers with `terraform init`.

- Deploy Kubernetes cluster running Help Users Vote with `terraform apply`.

## Development
- Contributions should be formatted with [hclfmt](https://github.com/fatih/hclfmt). Run `./hack/setup-githooks.sh` to check pre-commit.
