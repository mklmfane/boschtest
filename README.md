Infrastructure

Jenkins machine is used to orchestrate the CI/CD pipeline flow
Ansible Tower was used in the lab to create all infrastructure for this lab to provision the application
Vagrant was used to create the virtual machines repressening Ansible tower host, Jenkins, nexus and Sonar
Maven can manage, set and deploy a Java project.
GIT for source code management and control.
SonarSource to assess the code quality in the CI/CD pipeline.
Nexus or JFrog as the repository for artifact binaries.


An infrastructure architecture

ALM (Application Lifecycle Management) scenarios can be emulated within a POC environment to prove the CI/CD concept. 

SonarSource:  1 vCPU with 2028m RAM
Nexus: 1 vCPU with 1024m RAM
Application: 1 vCPU 512m RAM
Jenkins: 1 vCPU with 1024m RAM
A CI/CD POC with the aforementioned components contains the following architectural elements:

  1. Github -  where the project is hosted and where Jenkins will poll for changes to start the pipeline flow.

  2. SonarSource - source code analysis server. If anything goes wrong during the analysis (e.g. not enough unit tests), the flow is interrupted. This step is important to guarantee the source code quality index.

  3. Nexus or JFrog - is the artifact repository. After a successful compilation, unit tests and quality analyses, the binaries are uploaded into it. Later those binaries will be downloaded by Ansible during the application deployment.

  4. Ansible Playbook deployed using ansible tower by using a YAML file integrated in the application source code, deploys the Spring Boot App on to a CentOS machine.

  5. Jenkins - is our CI/CD process orchestrator. It is responsible to put all the pieces together, resulting in the application successfully deployed in the target machine.

  6. An Ansible Playbook can be used to provision the infrastructure, using roles from the Ansible Galaxy community. Ansible Galaxy a primary source to learn Ansible.  Often the environment for VMs is managed by Vagrant with libvirt.  Details can be accessed in the project Vagrant ALM at Github.

Pipeline Flow example

Demo environments should do the following pipeline, though real-world prod systems may have slightly more complicated flows depending on the use case, type of apps, existing legacy systems, etc.
