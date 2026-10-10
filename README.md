# Stock Dashboard on Azure with GitHub Actions

This project demonstrates a simple DevOps architecture for a Django application that displays live-ish stock data from Yahoo Finance (free source), deploys to an Azure Linux VM, and uses GitHub Actions for build and deployment.

## Objective

- Build a Python Django app
- Package it as a wheel file
- Deploy the wheel to a Linux VM in Azure
- Run the application and reverse proxy it via Nginx
- Use GitHub environment approval as a simple release gate

## Architecture

- GitHub repository stores code
- GitHub Actions builds the Python wheel
- GitHub Actions uploads the wheel as an artifact
- Deployment is triggered after approval in a GitHub Environment
- Azure VM hosts the app and Nginx
- The app runs behind gunicorn on port 8000

## Folder structure

- `stock_project/` : Django project
- `stock_dashboard/` : app logic and templates
- `terraform/` : Azure infrastructure as code
- `.github/workflows/` : CI/CD pipeline
- `scripts/` : install and deployment helper

## Local development

1. Create a virtual environment
2. Install dependencies
3. Run the Django app

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

Visit: http://localhost:8000

## Build the wheel

```bash
python3 -m pip install --upgrade build
python3 -m build --wheel
```

The wheel file will be generated in `dist/`.

## Cloud infrastructure

For this project, you can deploy to either Azure or GCP. The GCP example is ready in the `gcp/` directory.

```bash
cd gcp
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your GCP project values
terraform init
terraform plan
terraform apply
```

Before running `terraform apply`, update the `terraform.tfvars` file or set variables through environment variables.

## GitHub deployment

The workflow in `.github/workflows/deploy.yml` does the following:

1. Builds the wheel
2. Uploads it as an artifact
3. Uses an approval gate via GitHub Environment
4. Copies the wheel to the Linux VM on GCP or Azure
5. Installs and starts the app via a shell script

## Important notes

- Yahoo Finance is a free market data source, but it can have rate limits and occasional API changes.
- For production, use a stable partner API or a paid market-data provider.
- For strict deployment approvals, GitHub Environment protection rules are enough for a simple setup. A separate XLR/XL Release tool is optional but not required.

## Resources required

- GCP project
- VPC + subnet
- Linux VM (e.g., Ubuntu 22.04) on Compute Engine
- External IP
- Firewall rules for 22, 80, and 443
- GitHub repository
- GitHub Actions
- Optional: Cloud IAM, Secret Manager, monitoring, or DNS

## TFE / Terraform Enterprise

TFE is optional. For a small personal cloud deployment, you can keep it simple:

- use local Terraform in your repo
- run `terraform apply` from your laptop
- use GitHub environment approvals for release control

TFE is useful only when you want centralized remote state, policy enforcement, and team-based governance.
