# Terraform ProxySQL RDS

 A development environment which includes a webserver, a proxysql instance and an RDS instance for testing and experimentation with ProxySQL.

 First, Terraform is used to:
 
 * Generate a password for the RDS instance and store it in AWS secrets manager
 * Create 2 EC2 instances 
 * Create an RDS instance including 1 read replica, using the password from secrets manager

 Then, Ansible is used to:
 
 * Configure one EC2 instance as a webserver
 * Configure the other EC2 instance as a ProxySQL instance
 * Set up some test data on the RDS instance 

 ## You will need

 * AWS access key and secret with permission to create EC2 instances, RDS instances and read/write to AWS Secrets Manager

 ## Create the infrastructure

 > terraform apply

 ## Initial configuration

 * Update webserver_aws_ec2.yml with your AWS access key and secret, so it can configure the webserver EC2 instance based on its tag of 'webserver'
 * Update proxysql_aws_ec2.yml with your AWS access key and secret, so it can configure the webserver EC2 instance based on its tag of 'proxysql'

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

> aws secretsmanager delete-secret --secret-id rds_admin --force-delete-without-recovery --region eu-west-1