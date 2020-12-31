# Terraform ProxySQL RDS

 A development environment which includes a webserver, a proxysql instance and an RDS instance for testing/development.

 ## Configuration

Create an encrypted file using ansible-vault. This is to load the ec2_aws plugin so Ansible can identify your EC2 instances dynamically:

> ansible-vault create aws_ec2.yml

You will be asked to set and confirm a password. Add the following content to the aws_ec2.yml file, adding your AWS access key and secret

```
plugin: aws_ec2
regions:
  - eu-west-1
filters:
  tag:Name: webserver
aws_access_key_id: [ your aws access key ]
aws_secret_access_key: [ your aws secret key ]
```

 Run the Ansible playbook to configure the webserver, proxysql and the RDS instance:

> ansible-playbook -i aws_ec2.yml playbook.yml --ask-vault-pass

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