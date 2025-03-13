# crdb-terraform-ansible

## Outline
- [Security Notes](#security-notes) 
- [Directory Structure](#directory-structure)
- [Using the Terraform HCL](#using-the-terraform-hcl)
  - [Run This Terraform Script](#run-this-terraform-script)
    - [Prepare to run](#prepare)
    - [For Enterprise Features](#if-you-intend-to-use-enterprise-features-of-the-database)
    - [Kick off the script](#kick-off-terraform-script)
  - [Deploy to 2 regions](#deploy-to-2-regions-with-replicator)
    - [Run Terraform on each region](#run-terraform)
    - [Verify Deployments](#verify-deployment)
      - [Ensure replicator running](#ensure-replicator-is-running-on-each-region)
      - [Verify application running in each region](#verify-application-running-in-each-region)
    - [Deploy ChangeFeeds](#deploy-changefeeds)
    - [Add Grafana dashboards](#add-grafana-dashboards)
      - [Background and Links](#background-and-links)
      - [Specific Steps for Dashboards](#specific-steps-for-github)
  - [Technical Documentation](#technical-documentation)
    - [Azure Documentation](#azure-documentation)
      - [resize disk](#terraform-variable-crdbresizehomelv)
      - [Finding Images](#finding-images)
      - [Install Terraform](#install-terraform) 
      - [Install Azure CLI](#install-azure-cli)
      - [Azure Links](#azure-links)
    - [CockroachDB Links](#cockroachdb-links)
    - [Other Links](#general-links)
    - [Terraform/Ansible Description](#terraformansible-documentation)
    - [molt-replicator](#molt-replicator)
      - [Running molt-replicator](#running-molt-replicator) 
      - [molt-replicator links](#molt-replicator-links)
## Directory structure
Currently, this deployment github only supports AZURE but that will change to next include AWS and finally GCP.  The goal is 
to have minimal changes to the ansible for each of the cloud providers and this will be automated.  The subdirectories are:
* [ansible](ansible) contains the ansible scripts
* [terraform-aws](terraform-aws) contains the aws terraform code (not completed)
* [terraform-azure](terraform-azure) contains the azure terraform code

![Resources Created in the Terraform HCL](resources/azure-single-regon.drawio.png)

Terraform HCL to create a multi-node CockroachDB cluster in Azure.   The number of nodes can be a multiple of 3 and nodes will be evenly distributed between 3 Azure Zones.   Optionally, you can include
 - haproxy VM - the proxy will be configured to connect to the cluster
 - app VM - application node that includes software for a multi-region demo

## Security Notes
- `firewalld` has been disabled on all nodes (cluster, haproxy and app).   
- A security group is created and assigned with ports 22, 8080 and 26257 opened to a single IP address.  The address is configurable as an input variable (my-ip-address)  

## Using the Terraform HCL
To use the HCL, you will need to define an Azure SSH Key -- that will be used for all VMs created to provide SSH access.

### Run this Terraform Script
```terraform
# See the appendix below to intall Terrafrom, the Azure CLI and logging in to Azure

git clone https://github.com/jphaugla/crdb-terraform-ansible.git
cd crdb-terraform-ansible/
```

#### if you intend to use enterprise features of the database
This has changed with new enterprise license requirements.  Can now use without adding a license for an initial time period
add the enterprise license and the cluster organization to the following files in the region subdirectory under provisioners/temp So for example if the region is centralus, add the contents of your licence key to a file in provisioners/temp/centralus/enterprise_license
[enterprise_license](ansible/temp)   
[cluster_organization](ansible/temp)   
#### Prepare
* Use the terraform/ansible deployment using the subdirectories [region1](terraform-azure/region1) and/or [region2](terraform-azure/region2) in the deployment github
* Can enable/disable deployment of Kafka by setting the *include_ha_proxy* flag to "no" in [deploy main.tf](terraform-azure/region1/main.tf)
* Can enable/disable deployent of replicator using *start_replicator* flag in [main.tf](terraform-azure/region1/main.tf)
* Ensure *install_enterprise_keys* is set in [main.tf](terraform-azure/region1/main.tf)
* Depending on needs, decide whether to deploy kafka setting the *include_kafka* to yes or no in [main.tf](terraform-azure/region1/main.tf)
* Look up the IP address of your client workstation and put that IP address in *my_ip_address*
  * This allows your client workstation to access the nodes through their public IP address
  * This access is needed for the ansible scripts to perform necessary operations
* *NOTE:* Inside the application node, this [banking java application](https://github.com/jphaugla/CockroachDBearch-Digital-Banking-CockroachDB) will be deployed and configured
  * if no need for the application to run, kill the pid.  Easy to find the pid by doing a grep on java and killing the application job

#### Kick off terraform script
modify [main.tf](terraform-azure/region1/main.tf)
```
cd region1
terraform init
terraform plan
terraform apply
```
### Add Grafana Dashboards
#### Background and Links
Generic grafana prometheus plugin and grafana dashboard
[configure prometheus data source for grafana](https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/)
[import grafana dashboards](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/import-dashboards/)
Detailed steps are documented in the following grafana links for cockroachDB and replicator/replicator.
* [CockroachDB Grafana dashboards](https://www.cockroachlabs.com/docs/stable/monitor-cockroachdb-with-prometheus#step-5-visualize-metrics-in-grafana)
* [replicator/replicator](https://github.com/cockroachdb/replicator/wiki/Monitoring)
#### Specific steps for github
Prometheus and Grafana are configured and started by the ansible scripts.  Both are running as services on the haproxy node
* Look up the haproxy node address in the region subdirectory under [provisioners/temp](ansible/temp)
* Start the grafana interface using [grafana ui](localhost:3000).  
  * This grafana ui is the haproxy external node ip at port 3000
* Change the admin login password (original login is the installation default of admin/admin)
* [configure prometheus data source for grafana](https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/)
  * really this is:
    * adding the prometheus data source as documented in the link above
    * entering *http://localhost:9090* for the connection URL
    * scrolling to the bottom of the UI window
    * Click save and test
* [import grafana dashboards](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/import-dashboards/)
  * From the same grafana interface at [grafana ui](localhost:3000), Click on *Dashboards* using the above instructions
  * CockroachDB and replicator/terminator grafana dashboards are available within [grafana dashboards folder](scripts/grafana_dashboards)
    * These could be stale.  Refresh this folder using the [getGrafanaDashboards.sh](scripts/getGrafanaDashboards.sh)
    * import all the dashboards.  One of them is for replicator and the rest are cockroachDB dashboards
    * *NOTE:* [replicator.json](scripts/grafana_dashboards/replicator.json) is only needed if doing replicator
    
### clean up and remove everything that was created

```
terraform destroy
```
## Deploy to 2 regions with replicator

### Run Terraform
*  terraform apply in each region directory-reference the steps [noted above](#run-this-terraform-script)
* add license and cluster org to the provisioners/temp/<region>
```bash
git clone https://github.com/jphaugla/crdb-terraform-ansible.git
cd crdb-terraform-ansible/terraform-azure/region1
terraform init
terraform apply
cd crdb-terraform-ansible/terraform-azure/region2
terraform init
terraform apply
```
### Verify deployment
* This will deploy this [Digital-Banking-CockroachDB github](https://github.com/jphaugla/CockroachDBearch-Digital-Banking-CockroachDB) into the application node with connectivity to cockroachDB.  
  Additionally, replicator is deployed and running on the application node also with connectivity to haproxy and cockroachDB in the same region 

#### Ensure replicator is running on each region
```bash
cd ~/crdb-terraform-ansible/provisioners/temp/{region_name}
ssh -i path_to_ssh_file adminuser@`cat app_external_ip.txt`
ps -ef |grep replicator
# if it is not running, start it
cd /opt
./start.sh
```
#### Verify application running in each region
*  NOTE:  this compiling and starting of the application step has been automated in terraform so only for debug/understanding
* The java application needs to be started manually on the application node for each region.  Set up the [environment file](scripts/setEnv.sh)
  * the ip addresses can be found in a subdirectory under [temp](ansible/temp) for each deployed region
  * Make sure to set the COCKROACH_HOST environment variable to the private IP address for the haproxy node
  * If using kafka, KAFKA_HOST should be set to the internal IP address for kafka
  * set the REGION to the correct region
* do on each region
```bash
# NOTE: this should already be running.  If not running check log files in /mnt/datat1/bank-app
# steps below will rerun
cd ~/crdb-terraform-ansible/provisioners/temp/{region_name}
ssh -i path_to_ssh_file adminuser@`cat app_external_ip.txt`
cd Digital-Banking-CockroachDB
# edit scripts/setEnv.sh as documented above
source scripts/setEnv.sh
mvn clean package
java -jar target/cockroach-0.0.1-SNAPSHOT.jar
```

### Deploy changefeeds
* The necessary manual step is to deploy a [CockroachDB Changefeed](https://www.cockroachlabs.com/docs/stable/create-changefeed) across the regions to make active/active replicator between the two otherwise independent regions
  * Port 30004 is open on both regions to allow the changefeed to communicate with the application server on the other region
* Start the changefeed on each side with changefeed pointing to the other sids's application node external IP address
* The changefeed script is written on each of the cockroach database nodes by the terraform script.  Login to any of the cockroach
  nodes using the IP address in [temp](ansible/temp) for each deployed region.
  * As previously mentioned, the changefeed script must be modified to point to the application external IP address for the other region
  * this is the step that reaches across to the other region as everything else is within region boundaries
* IMPORTANT NOTE:  Must have enterprise license for the changefeed to be enabled
  * see [changefeed documentation](https://www.cockroachlabs.com/docs/stable/licensing-faqs#set-a-license)
* Two different changefeeds are provided in the home directory for the adminuser on any of the cockroachDB nodes:  Banking application or cockroach kv workload
  * In either case, edit the corresponding sql script using the external IP address for other regions application node  
  * Banking application
    * edit create-changefeed.sql replacing the IP address before port number 30004, with the external IP address for other regions application node
    * create-changefeed.sh-creates a changefeed for the banking application
  * Cockraoch kv workload
    * edit create-changefeed-kv.sql replacing the IP address before port number 30004, with the external IP address for other regions application node
    * create-changefeed-kv.sh-creates a changefeed for the [cockroachdb kv workload](https://www.cockroachlabs.com/docs/stable/cockroach-workload)
```bash
cd ~/crdb-terraform-ansible/provisioners/temp/{region_name}
ssh -i path_to_ssh_file adminuser@`cat crdb_external_ip{any ip_address}`
# edit create-changefeed.sh putting the app node external IP address for the other region
cockroach sql --certs-dir=certs
SET CLUSTER SETTING cluster.organization = 'Acme Company';
SET CLUSTER SETTING enterprise.license = 'xxxxxxxxxxxx';
exit
# two different changefeed scripts are provided
vi create-changefeed-kv.sql
# or 
vi create-changefeed.sql
./create-changefeed-kv.sh
 # or 
 ./create-changefeed.sh
```
Verify rows are flowing across from either region by running additional [test application steps](https://github.com/jphaugla/CockroachDBearch-Digital-Banking-CockroachDB/test-application) 
or run sample kv workload from the adminuser home in the application node application machine using the provided *kv-workload.sh* script


## Technical Documentation

### Azure Documentation
#### terraform variable crdb_resize_homelv
In Azure, any additional space allocated to a disk beyond the size of the image, is available but unused.  Setting the variable `crdb_resize_homelv` to "yes", will cause the user_data script to attempt to resize the home logical volume to take advantage of the additional space.  This is potentially dangerous and should only be used if you're sure that sda2 is the volume group with the homelv partition.  Typically, if you're using the standard redhat source image defined in by the instance.tf you should be fine.

#### Finding images
```
az vm image list -p "Canonical"
az vm image list -p "Microsoft"
```

#### Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

#### Install Azure CLI
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
for RHEL 8
sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo dnf install azure-cli

az upgrade
az version
az login (directs you to a browser login with a code -- once authenticated, your credentials will be displayed in the terminal)

#### Azure Links:
Microsoft Terraform Docs
https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform
Sizes for VM machines (not very helpful)
https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
User Data that is a static SH 
https://github.com/guillermo-musumeci/terraform-azure-vm-bootstrapping-2/blob/master/linux-vm-main.tf

#### CockroachDB Links
* [CockroachDB Grafana dashboards](https://www.cockroachlabs.com/docs/stable/monitor-cockroachdb-with-prometheus#step-5-visualize-metrics-in-grafana)

#### General Links
[configure prometheus data source for grafana](https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/)
[import grafana dashboards](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/import-dashboards/)

### Terraform/Ansible Documentation
* [terraform.tfvars](terraform.tfvars) and [vars.tf](terraform-azure/vars.tf) have important parameters.  
* Each node type has its own tf file
  * [application node *app.tf*](terraform-azure/app.tf)
  * [kafka node *kafka.tf*](terraform-azure/kafka.tf)
  * [haproxy node *haproxy.tf*](terraform-azure/haproxy.tf)
  * [cockroachDB node *instance.tf*](terraform-azure/instance.tf)
* Network components including security groups with port permissions are in [network.tf](terraform-azure/network.tf)
* Can use either of the regions subdirectories to kick off the deployment.  Both regions are defined to enable replicator deployment
  * [region1](terraform-azure/region1/main.tf) 
  * [region2](terraform-azure/region2/main.tf)
* These files connect terraform and ansible
  * template file at [inventory.tpl](terraform-azure/templates/inventory.tpl)
  * [provisioning.tf](terraform-azure/provisioning.tf) 
  * [inventory.tf](terraform-azure/inventory.tf)
* Ansible code is in the [provisioners/roles](ansible/roles) subdirectory
  * [playbook.yml](ansible/playbook.yml) 
    * Each node group has ansible code to export the node's private and public ip addresses to a region subdirectory under [ansible/temp](ansible/temp)
    * [haproxy-node](ansible/roles/haproxy-node)  doesn't have any additional installation
    * [app-node](ansible/roles/app-node) creates an application node running replicator and a Digital Banking java application 
      * banking java application is [installed](ansible/roles/app-node/tasks/package-java-app.yml) and [started](provisioners/roles/app-node/tasks/start-java-app.yml)
        * banking java application needs these tasks to run as well:
          * [java installed](ansible/roles/app-node/tasks/install-java-maven-go.yml)
          * [make der certs](ansible/roles/app-node/tasks/create-der-certs.yml)
          * [ensure git installed](ansible/roles/app-node/tasks/install-git.yml) and [bank github cloned](provisioners/roles/app-node/tasks/add-githubs.yml)
    * [replicator](provisioners/roles/replicator) creates replicator and molt deployment
      * replicator is [installed](ansible/roles/app-node/tasks/install-replicator.yml) and [started](provisioners/roles/app-node/tasks/create-replicator.yml)
      * molt is also [installed](ansible/roles/replicator/tasks/install-molt.yml)
      * molt can be executed using a sample script copied to the application node with /opt/molt-fetch.sh
      * replicator needs [node.js installed](ansible/roles/app-node/tasks/install-nodejs-typescript.yml)
    * [kafka-node](ansible/roles/kafka-node)
      * [confluent installed](ansible/roles/kafka-node/tasks/confluent-install.yml)
      * [confluent connect plug-ins](ansible/roles/kafka-node/tasks/confluent-connect-plug.yml)
      * [confluent start](ansible/roles/kafka-node/tasks/confluent-start.yml)
      * [confluent add connectors](ansible/roles/kafka-node/tasks/confluent-add-connectors.yml)
    * [crdb-node](ansible/roles/crdb-node)
      * For using replicator, a changefeed script is [created](ansible/roles/kafka-node/tasks/main.yml) using a [j2 template](provisioners/roles/crdb-node/templates/create-changefeed.j2)
  * Under each of these node groups
    * A vars/main.yml file has variable flags to enable/disable processing
    * A tasks/main.yml calls the required tasks to do the actual processing
    * A templates directory has j2 files allowing environment variable and other substitution
## Molt-replicator
* Molt replicator is no longer used for 2 region/DC deployments of CockroachDB but is part of zero downtime migration with molt
* 2 region/DC deployments of CockroachDB use Logical Data Replication or Physical Cluster Replication [see below](#two-datacenter-solutions)
* This github enables but does not fully automate migration and replication from PostgreSQL to CockroachDB
  * On AWS, an S3 bucket is created to enable the migration
  * Scripts are created on the application node with the correct connection strings for this github's deployments
### Running molt-replicator
To run molt-replicator (NOTE: currently this only works when deploying on AWS)
* Turn on the processing for molt-replicator with the terraform variable *setup_migration* in [main.tf](https://github.com/jphaugla/crdb-terraform-ansible/blob/main/terraform-aws/region1/main.tf)
* Use the scripts created on the application node in /home/ec2-user/
  * Login to application node
  * Dump the DDL for the already created employees database in postgres
``` bash
./pg_dump_employees.sh
```
  * Convert the resulting employees database DDL from PostgreSQL to CockroachDB
``` bash
./molt_convert.sh
```
  * Edit the resulting file to use a new database, *employees* instead of creating a new schema *employees*
    * change the line *CREATE SCHEMA employees;* to *CREATE DATABASE employees; use employees;*
    * remove every occurrence of *ALTER SCHEMA employees OWNER TO postgres;*
  * Create the *employees* database in CockroachDB
```bash
./runit.sh
```
  * Push the data from postgreSQL through the S3 to CockroachDB
```bash
 ./molt_s3.sh 
 ```
### Molt replicator links
* [cockroachDB create changefeed](https://www.cockroachlabs.com/docs/stable/create-changefeed)
* [Migration Overview](https://www.cockroachlabs.com/docs/stable/migration-overview)
* [replicator/replicator grafana dashboards](https://github.com/cockroachdb/replicator/wiki/Monitoring)
* [MOLT schema conversion](https://www.cockroachlabs.com/docs/cockroachcloud/migrations-page)
* [MOLT docker example](https://github.com/viragtripathi/cockroach-collections/tree/main/scripts/cockroach-molt-demo)
* [MOLT Fetch](https://www.cockroachlabs.com/docs/molt/molt-fetch)
* [Migrate from PostgreSQL](https://www.cockroachlabs.com/docs/stable/migrate-from-postgres)
## Two Datacenter Solutions
### Two Datacenter Links
* [Logical Data Replication blog](https://www.cockroachlabs.com/blog/logical-data-replication/)
* [Physical Cluster Replication Documentation](https://www.cockroachlabs.com/docs/stable/physical-cluster-replication-overview)
* [Logical Data Replication Documentation](https://www.cockroachlabs.com/docs/stable/logical-data-replication-overview)
## dbworkload
dbworkload is installed as part of the ansible set up.  A script to run is also configured with the correct IP addresses for running dbworkload with a standard banking demo as described in this [dbworkload project home](https://pypi.org/project/dbworkload/)
### using dbworkload
```bash
cd /opt/dbworkload
./dbworkload.sh
```

## To tear it all down
NOTE:  on teardown, may see failures on delete of some azure components.  Re-running the destroy command is an option but sometime a force delete is needed on the OS disk drives of some nodes
```bash
terraform destroy
```
