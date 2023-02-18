# mbdt-infrastructure
----
**ABSTRACT:** Terraform scripts are being used manage our infrastructure as code (IaC) and to help us create AWS resources for `AeroCloud-OntologyHub` project which includes IAM Roles, EC2 Instances, ECS (Fargate) clusters & services, Task Definitions, L4 & L7 Load Balancers, Target Groups & Routing Rules, Security Groups, Route53 DNS records and anything & everything else we can imagine... The terraform scripts can be executed the via CLI or through jenkins pipelines.  

**OVERVIEW:** When Terraform is getting ready to do stuff (i.e. planning, applying or destroying resources), the CLI tool searches for valid .tf-files in the current working directory (AKA: 'tf-root'). Before the terraform executable does anything, all those files are sorted (alphanumerically) and then merged into a single file which then gets used with whatever command that fired it. This can be used to our advantage in order to help with transparency and management of Terraform files - as it allows us to segregate specialized code (such that used for providers, resources and outputs) into different, smaller, and easier-to-read files that are grouped according to what they do. Typically you'd see separate tf files for main, variables, and outputs - but there are no rules. Other files like tfvars files are hadled in a simlar fashion but are applied using a different order of precedence. Although terraform usage is outside of the scope of this document, there are plenty of resources available on hashicorp's website. The book I found most useful was __O'REILLY: Terraform Up & Running__ and theis was used as a guide for best-practices.

**STANDARDS:** For this project, I try to keep all the helper-scripts in the git-root, and keep all the terraform files in the tf-root AKA: "ontologyhub-tf". Soon there may also be a "ontologyhub-ans" for ansible stuff, etc... I also like to keep a README.md in each directory with the necessary details needed for that level of documentation.

**Directory Structure (updated for v0.3)**
```
.
├── assume-aws-role.sh    (helper script for multi-account mgmt via IAM roles)
├── jenkinsfile    (declarative groovy file used to define the ci/cd pipeline)
├── ontologyhub-tf   (formerly: mbdt-tf - this is where all the magic happens)
│   ├── alb01_rules.tf (this is where all the forwarding rules live - for now)
│   ├── alb01.tf  (the new load balancer - TESTED: 29-DEC)
│   ├── artifacts (temp folder for build artifacts)
│   │   ├── 2022jan05-133951-est-qa-tf-iac-jenkins.tfplan 
│   │   └── 2022jan05-133951-est-qa-tf-iac-jenkins.txt
│   ├── configs (previously broken & completely undocumented - now works in QA)
│   │   ├── default.tfvars
│   │   ├── prod.tfvars
│   │   ├── qa.tfvars     (Joe's new & improved version of below)
│   │   └── qa.tfvars.edx (this was inherited from the EDX team)
│   ├── locals.tf 
│   ├── main.tf (this is where it all begins)
│   ├── modules (this is new - as of December)
│   │   ├── alb01_rules_helper (this is new)
│   │   │   ├── main.tf
│   │   │   ├── README.md
│   │   │   └── variables.tf
│   │   └── svc_template (work in progress for SKOS)
│   │       ├── main.tf
│   │       └── variables.tf
│   ├── provider.tf (tweaked for)
│   ├── svc_lode.tf         (TESTED: 29-DEC)
│   ├── svc_portal.tf       (TESTED: 29-DEC)
│   ├── svc_publisher.tf    (TESTED: 29-DEC)
│   ├── svc_skos.tf.disabled  (in-progress)
│   ├── svc_webvowl.tf      (TESTED: 29-DEC)
│   └── variables.tf
├── README.md
├── tf-disable (helper script to quickly disable tf code)
├── tf-easy.sh (change aws-role, get s3-state & do tf:init/validate/plan all-in-one)
├── tf-enable (helper script to quickly enable tf code)
└── WIP-Jenkins.txt
 

    2 directories, 14 files

```

## Change History 
---
### v0.0 - (2021-JUL) tf-iac branch handed off from the EDX team  
---
### v0.1 - (2021-NOV) tf-iac-qa branched from above by Joe Negron
GOAL: Discovery & Refactor (PHASE-1)
- ADD: now includes cross-account functionality for multiple environments
- ADD: new assume-aws-role.sh enhancements using AWS STS for multiple accounts
- FIX: fully functional s3-backend maintained in each environment (no more manual copying)
- ADD: tf-switch to facilitate terraform version updates from beta v0.13.5 to v1.x.x
- ADD: tf-easy.sh to do tf-init, pull state from s3, format & validate the code, & create a tf-plan
- FIX: eliminated errors & warnings to reduce deploy times by half (now less than one-hour)
- ADD: tf-graph and visualizer to help identify deltas in new tf-plan files
- BUG: identified bug in terraform aws provider & submitted issue to maintainers for resolution
- MOD: remove tf-workspaces (design flaw) for better scalability
- REQ: Pull request made for code fully-tested & demo'd in the QA environment 
---
### v0.2 - (2021-DEC) tf-iac-alb branched from above by Joe Negron
GOAL: a single ALB for all ECS services as frontend to above fargate cluster and triggered from Jenkins
- ADD: new module as rules-helper for ALB01
- MOD: refactor for breaking changes in tf-v1.x
- ADD: audits & housekeeping for assume-role helper
- MOD: begin scaffolding for new containers module
- ADD: create terraform.log & aws.log for auditing & compliance
- ADD: install jenkins-agent on iac-mgmt server and 
- ADD: integration with jenkins-master via SSH using PKI
- REM: eliminated broken jenkins terraform-plugin inehrited from EDX (abandoned in 2018)
- ADD: jenkinsfile for simple pipeline to apply tf-plan from above with Auto-Approve
- FIX: jenkins git-plugin no longer uses headless-mode for git-fetch
- ADD: jenkins service-account implemented & hardened for compliance
- FIX: backup & restore unix permissions using git-hooks (pre-commit & post-fetch)
- FIX: aws tf-provider now fixed in v3.69+ to eliminate BUG from above
- ADD: groovy-script logic for 3-stage conditional pipeline
- ADD: Human approval gates before APPLY stage  
- ADD: DNS & wildcard certs for qa.ontologyhub.utc.com (manually)

**Test Results:**
```
Success: 17, Failures: 4
OK:   test_base_blogs_has_itar_banner
OK:   test_base_blogs_howto_name_title
OK:   test_base_blogs_should403
OK:   test_base_blogs_wildcard
OK:   test_base_has_itar_banner
OK:   test_base_mobi_training_slide_badname
OK:   test_base_mobi_training_slide_download
OK:   test_base_mobi_training_title
FAIL: test_base_status
OK:   test_base_title
OK:   test_catalog_title
OK:   test_lode_extract_page
FAIL: test_mobi_api_get_users      
FAIL: test_mobi_api_get_users_badlink   
FAIL: test_mobi_title
OK:   test_publisher_title
OK:   test_vocabularies_invalid_resource_lode
OK:   test_vocabularies_invalid_resource_rdf
OK:   test_vocabularies_wildcard_lode
OK:   test_vocabularies_wildcard_rdf
OK:   test_webvowl_default_page

```
--- 
### v0.3 - (2022-JAN) tf-iac-elb branched from above by Joe Negron
GOAL: ELB in front of ALB for all ECS services as FE to above fargate cluster via jenkins+tf
- MOD: routing rules to ALB01 as per spec
- FIX: streamlined EDX code for containers to eliminate individual ALBs
- ADD: helper scripts to quickly enable & disable tf files
- MOD: simplified dir structure for git-root & tf-root 
- ADD: DNS & wildcard certs for qa.ontologyhub.rtx.com (manually)

test with existing jenkins pipelines
---


## Apps
----
There are 4 apps for which AWS infrastructure will be created. Apps are listed below
- lode
- portal
- publisher
- webvowl
- skos (comming soon)

## Variables
----
All the variables are declared in [terraform.auto.tfvars](terraform.auto.tfvars) file (THIS IS ONLY PART TRUE)
1. the file does not exist 
1. if it did it would be used as an alternative to using the "-var-file" flag. Files named with the ".auto.tfvars" extension will be loaded automatically, similar to the "terraform.tfvars" file. 
1. Since they are using multiple environments there are XXX.tfvars files in the config folder - where XXX = the environment name (i.e. dev, qa & prod). This is the only way to manage resources in multiple environments but does not address multiple AWS accounts or access via roles

(more to follow - this is a critical part of the design and must be updated later)

<br />

### Explanation of variables
----
| Variable Name                 | Explanation   |
| :---                          | :---          |
| region                        | aws region in which resources will be created |
| stage                         | stage name that will append with resources |
| indicated_workspace           | workspace name to append with resources |
| label_namespace               | label namespace for the resources |
| label_name                    | label name used for tagging |
| tag_data_classification       | variable for the classification of tags |
| tag_organization              | organization name for tagging |
| tag_business_unit             | business unit for tagging |
| tag_tool                      | tool name for tagging |
| tag_author                    | author name that will create resources |
| tag_team                      | team name that will create resources |
| tag_project                   | project name for tagging |
| vpc                           | vpc tags key/value in which resources will be created |
| route53_hostedzone_private    | route53 hosted zone to create dns records |
| profile                       | aws profile name used to  create resources |
| acm_certificate_arn           | ssl certificates arn used by application load balancer |

<br />

## Files and  Apps Components
----
### [main.tf](main.tf)
----
This file contains ECS cluster resource creation and also calling existing aws resources using data sources for the refrence in other newly created resources. Everything below this looks like a lot of boilerplate cut & paste to satisfy the documentation requirement.

### [svc_lode.tf](svc_lode.tf)
----
In this file, AWS resources belonging to `lode` service are creating, this includes ECR Repository, ECS Service, Task Definition, CloudWatch logs group, Application Load Balancer, Listeners, Target Groups, Security Groups, IAM role and Route53 DNS record. 

### [svc_portal.tf](svc_portal.tf)
----
In this file, AWS resources belonging to `portal` service are creating, this includes ECR Repository, ECS Service, Task Definition, CloudWatch logs group, Application Load Balancer, Listeners, Target Groups, Security Groups, IAM role and Route53 DNS record. 

### [svc_publisher.tf](svc_publisher.tf)
----
In this file, AWS resources belonging to `publisher` service are creating, this includes ECR Repository, ECS Service, Task Definition, CloudWatch logs group, Application Load Balancer, Listeners, Target Groups, Security Groups, IAM role and Route53 DNS record. 

### [svc_webvowl.tf](svc_webvowl.tf)
----
In this file, AWS resources belonging to `webvowl` service are creating, this includes ECR Repository, ECS Service, Task Definition, CloudWatch logs group, Application Load Balancer, Listeners, Target Groups, Security Groups, IAM role and Route53 DNS record. 


## Terraform Version (tested)
    Terraform => v1.1.2    

21-1108JN-NOTE: as of this writing, the latest version of terraform is v1.1.2 and v1.2.0 is currently in beta [terraform-versions](https://releases.hashicorp.com/terraform/)

## Deploying Infrastructure
----
Edit [terraform.auto.tfvars](terraform.auto.tfvars) file and replace variable values according to your environment then follow the steps below:
(No "*auto.tfvars" file was ever committed to this repo - more to follow...)

    tfswitch $VERSION		     #A foss tool added by Joe that facilitates downloading & working with different versions of terraform [SOURCE](https://github.com/warrensbox/terraform-switcher)
    export AWS_PROFILE={dev,qa,prod}   #Sets the named-profile to be used by terraform which has the rights to the appropriate environment and target account [MORE INFO](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
    terraform init                     #Initializes terraform
    terraform validate (added)
    terraform plan                     #Creates an execution plan
    terraform apply                    #Execute the plan   



## Deleting Infrastructure
----    
    terraform destroy                  #This will destory all the resources

## Additional Notes
Per the Terraform documentation on the [Dependency Lock File](https://www.terraform.io/docs/language/dependency-lock.html):

Terraform automatically creates or updates the dependency lock file each time you run the terraform init command. You should include this file in your version control repository so that you can discuss potential changes to your external dependencies via code review, just as you would discuss potential changes to your configuration itself.

The key to understanding why you should commit that file is found in the following section on Dependency Installation Behavior:

When terraform init is working on installing all of the providers needed for a configuration, Terraform considers both the version constraints in the configuration and the version selections recorded in the lock file.

If a particular provider has no existing recorded selection, Terraform will select the newest available version that matches the given version constraint, and then update the lock file to include that selection.

If a particular provider already has a selection recorded in the lock file, Terraform will always re-select that version for installation, even if a newer version has become available. You can override that behavior by adding the -upgrade option when you run terraform init, in which case Terraform will disregard the existing selections and once again select the newest available version matching the version constraint.

Essentially this is intended to have Terraform continue to use the version of the provider selected when you added it. If you do not checkin the lock file, you will always be automatically upgraded to the latest version that obeys the constraint in code, which could lead to unintended consequences.

Note: You can force Terraform to upgrade when doing the init call by passing the -upgrade flag.
