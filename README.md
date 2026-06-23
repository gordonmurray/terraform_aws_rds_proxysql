# Terraform ProxySQL RDS

 A development environment which includes a webserver, a proxysql instance and an RDS instance for testing and experimentation with ProxySQL.

 First, Terraform is used to:
 
 * Generate a password for the RDS instance and store it in AWS Secrets Manager
 * Create 2 EC2 instances 
 * Create an RDS instance including 1 read replica, using the password from Secrets Manager

 Then, Ansible is used to:
 
 * Configure one EC2 instance as a webserver
 * Configure the other EC2 instance as a ProxySQL instance
 * Set up some test data on the RDS instance 

 ## You will need

 * Terraform >= 1.5 (OpenTofu also works — Terraform moved to the BSL licence at 1.6, OpenTofu is the open-source fork)
 * AWS access key and secret with permission to create EC2 instances, RDS instances and read/write to AWS Secrets Manager

 ## Local checks

 This repo uses [pre-commit](https://pre-commit.com) to run `terraform fmt`, `tflint`, `ansible-lint` and a few whitespace/end-of-file checks before each commit. Install it once after cloning:

 ```
 pre-commit install
 ```

 ## Variables

 Terraform needs a few inputs. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` (gitignored) and fill them in:

 | Name | Type | Required | Description |
 |------|------|----------|-------------|
 | `region` | string | no (default `us-east-1`) | AWS region to deploy into |
 | `vpc` | string | yes | VPC ID the EC2 instances and RDS go into |
 | `subnets` | list(string) | yes | Subnet IDs in that VPC (RDS needs at least two AZs) |
 | `my_ip_address` | string | yes | Your public IP; a `/32` SSH and HTTP allow rule is created for it |
 | `ssh_public_key_path` | string | yes | Path to the SSH public key registered as the EC2 key pair |
 | `disable_api_termination` | bool | no (default `false`) | Termination protection on the EC2 instances |

 ## Create the infrastructure

 > terraform apply

 ## Initial configuration

 The dynamic inventories (`webserver_aws_ec2.yml` and `proxysql_aws_ec2.yml`) find the EC2 instances by their `Name` tag. They use your normal AWS credentials from the standard chain — export `AWS_PROFILE` (or `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`) and `AWS_REGION`, the same as Terraform — so there's nothing to paste into the files. Set `AWS_REGION` to the same region as the Terraform `region` variable (default `us-east-1`).

 The ProxySQL admin, application-user and monitor-user passwords come from an Ansible Vault file rather than being hardcoded. Set them up once:

 ```
 cd ansible
 cp group_vars/all/vault.yml.example group_vars/all/vault.yml
 # edit group_vars/all/vault.yml and set real passwords, then encrypt it:
 ansible-vault encrypt group_vars/all/vault.yml
 ```

 Then pass `--ask-vault-pass` (or `--vault-password-file`) to the `ansible-playbook` commands below. The real `vault.yml` is gitignored.

Run the Ansible playbook to configure the RDS instance, it will create a database and a user:

> ansible-playbook rds.yml

Run the Ansible playbook to configure the webserver, it will install Apache, PHP and adminer:

 > ansible-playbook -i webserver_aws_ec2.yml webserver.yml  

Run the Ansible playbook to configure the proxysql instance, it will add a hostgroup, host and user:

 > ansible-playbook -i proxysql_aws_ec2.yml proxysql.yml  

 Once the above have been run, you can connect to the database via the proxy address, using Adminer on the webserver at http://{webserver_public_ip}/adminer.php

## Cost estimate, provided by Infracost:

```
  NAME                                       MONTHLY QTY  UNIT         PRICE   HOURLY COST  MONTHLY COST  

  aws_db_instance.database_main                                                                           
  ├─ Database instance                               730  hours        0.0180       0.0180       13.1400  
  ├─ Database storage                                 20  GB-months    0.1380       0.0038        2.7600  
  └─ Database storage IOPS                             0  IOPS-months  0.1100       0.0000        0.0000  
  Total                                                                             0.0218       15.9000  
                                                                                                          
  aws_db_instance.database_replica                                                                        
  ├─ Database instance                               730  hours        0.0180       0.0180       13.1400  
  ├─ Database storage                                 20  GB-months    0.1380       0.0038        2.7600  
  └─ Database storage IOPS                             0  IOPS-months  0.1100       0.0000        0.0000  
  Total                                                                             0.0218       15.9000  
                                                                                                          
  aws_instance.proxysql                                                                                   
  ├─ Linux/UNIX usage (on-demand, t3a.nano)          730  hours        0.0051       0.0051        3.7230  
  ├─ CPU credits                                       -  vCPU-hours   0.0000            -             -  
  └─ root_block_device                       
     └─ General Purpose SSD storage (gp2)              8  GB-months    0.1100       0.0012        0.8800  
  Total                                                                             0.0063        4.6030  
                                                                                                          
  aws_instance.webserver                                                                                  
  ├─ Linux/UNIX usage (on-demand, t3a.nano)          730  hours        0.0051       0.0051        3.7230  
  ├─ CPU credits                                       -  vCPU-hours   0.0000            -             -  
  └─ root_block_device                       
     └─ General Purpose SSD storage (gp2)              8  GB-months    0.1100       0.0012        0.8800  
  Total                                                                             0.0063        4.6030  
                                                                                                          
  OVERALL TOTAL (USD)                                                               0.0562       41.0060  

2 resource types weren't estimated as they're not supported yet.
Please watch/star https://github.com/infracost/infracost as new resources are added regularly.
1 x aws_secretsmanager_secret_version
1 x aws_secretsmanager_secret
```


## Troubleshooting

If Terraform gives an error related to a secret with this name is already scheduled for deletion use the following to force deleting the secret:

> aws secretsmanager delete-secret --secret-id rds --force-delete-without-recovery --region "$AWS_REGION"