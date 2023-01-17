# Terraform Linode Kubernetes Deploy
## Project details
### Basic
Run app by using run.sh in the main folder. This needs -a <linode_token> -s <ssh_key> to work.
## Project structure 
### root
Contains folders, git files and run.sh which starts app.
### bin
This is where terraform binary is placed
### deploy_lib
Folder for the deployment related scripts. Most of the projects logic should be here.
### tf
Terraform related files.
### work
This folder is generated when script is ran, it contains copy of project but with altered config files
