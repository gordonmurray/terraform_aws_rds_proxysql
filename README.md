# Terraform ProxySQL RDS

 A development environment with a webserver, a proxysql instance and an RDS instance for testing/development 




 # Configuration

 Run the Ansible playbook th configure the webserver, proxysql and the RDS instance.

 > ansible-playbook -i aws_ec2.yml playbook.yml --ask-vault-pass  

--------------------

If Terraform gives an error related to a secret with this name is already scheduled for deletion:

> aws secretsmanager delete-secret --secret-id rds_admin --force-delete-without-recovery --region eu-west-1

## Cost estimate in eu-west-1, provided by Infracost:

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