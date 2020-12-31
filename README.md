# Terraform ProxySQL RDS

 A development environment with a webserver, a proxysql instance and an RDS instance for testing/development 

--------------------

If Terraform gives an error related to a secret with this name is already scheduled for deletion:

> aws secretsmanager delete-secret --secret-id rds_admin --force-delete-without-recovery --region eu-west-1

## Cost estimate in eu-west-1, provided by Infracost:

```
  NAME                                       MONTHLY QTY  UNIT        PRICE   HOURLY COST  MONTHLY COST  

  aws_db_instance.database                                                                               
  ├─ Database instance                               730  hours       0.0180       0.0180       13.1400  
  └─ Database storage                                 20  GB-months   0.1270       0.0035        2.5400  
  Total                                                                            0.0215       15.6800  
                                                                                                         
  aws_instance.proxysql                                                                                  
  ├─ Linux/UNIX usage (on-demand, t3a.nano)          730  hours       0.0051       0.0051        3.7230  
  ├─ CPU credits                                       -  vCPU-hours  0.0000            -             -  
  └─ root_block_device                       
     └─ General Purpose SSD storage (gp2)              8  GB-months   0.1100       0.0012        0.8800  
  Total                                                                            0.0063        4.6030  
                                                                                                         
  aws_instance.webserver                                                                                 
  ├─ Linux/UNIX usage (on-demand, t3a.nano)          730  hours       0.0051       0.0051        3.7230  
  ├─ CPU credits                                       -  vCPU-hours  0.0000            -             -  
  └─ root_block_device                       
     └─ General Purpose SSD storage (gp2)              8  GB-months   0.1100       0.0012        0.8800  
  Total                                                                            0.0063        4.6030  
                                                                                                         
  OVERALL TOTAL (USD)                                                              0.0341       24.8860  

2 resource types weren't estimated as they're not supported yet.
Please watch/star https://github.com/infracost/infracost as new resources are added regularly.
1 x aws_secretsmanager_secret
1 x aws_secretsmanager_secret_version

```