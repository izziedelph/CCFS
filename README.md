CLOUD ARCHITECTURE WITH TERRAFORM FOR A SMALL BUT BOOMING BUSINESS  
Porject Overview: Crawley Caribbean Food Service is a small but increasingly growing food chain in Crawley West Sussex. It specialises in Caribbean food. They do both restaurant dine-in and deliveries however since it is the only service in the area and there is an increasing number of Caribbean community, the customer demand has grown recently. This spike in demand has prompted the business to move to the cloud. CCFS requires scalable, flexible, and cost-efficient solutions hence the demand for a web-application. They require a reliable, scalable infrastructure to handle fluctuating customer demand especially on weekends, bank holidays and holiday seasons. This beginner project will build a cloud architecture for this business' demand.

Challenges: The main challenge I encountered was Auto Scaling Groups (ASG) that kept spinning up instances as I had set the minimum to 2. I was keen to incorporate as many concepts to this projects especially Devops CI-CD piplelines/woprklow with Github actions. At some point I realised that the instances were constantly running due to the automatic trigger in my workflow. Everytime I committed my changes to version control, my workflow.yml file would trigger new instances and this didn’t help as I wanted to clean up resources immediately after verifying that terraform was creating these resources in my AWS console to avoid incurring any charges. I used S3 for storing state files (remote)  and database for writing its state into the bucket. Through terraform, the database was able to write its sate into S3 and we could that state with our web server. This meant that whenever we ran terraform init, we had to be careful what the backend configuration was in order for terraform to read the state properly. Going back to local state file configuration meant deleting or commenting out remote state store, terraform S3 bucket block of code and running terraform init again.

Approach: Currently I have used EC2 for compute power, servers etc, ELB for high availability (ASG need to exist for ELB application). I plan to add S3 for storage, RDS for database management. The idea is to use terraform to write up the entire infrastructure and see it come to life. I also intend to track, commit all changes in some form of version control/Github. 

Solutions: Even if I was keen to incorporate as many cloud practices as possible, Iac, CI-CD etc my initial attempt at using Github actions to create a workflow failed. My first mistake was adding terraform apply to the workflow which I then removed and only allowed the workflow to run terraform plan. This was to avoid the constant spinning up of instances due to ASG (min=2 max=10). I preferred spinning up these instances or runnning terraform apply locally in my mac Terminal. For some reason I cannot explain, this did not work and every time I updated my main.tf file, and committed the changes to Github, my workflow continued spinning up instances. I also tried running terraform destroy manually with a separate .yml file specially for this reason. This only worked once and I was still unable to conveniently have control over these instances and delete them when I wanted. I had to eventually settle with deleting my workflow folder in my CCFS repository which had both ci-cd.yml and destroy.yml files in it.  

Lessons learned : I have learnt going forward that terraform apply is very delicate and cannot just be part of any workflow without careful consideration. It’s important to understand what stages you plan to add it to your code, testing, production etc. It is also important to acknowledge the delicacy of terraform destroy and it should also have limitations regarding the working environment. It should not just be run especially when you have a separate manual trigger (destroy.yml) like in my case. Since this was my initial/beginner project, I wasn’t too fussed on what worked and what didn’t. I was more interested in the lessons, seeing things in terraform translate into the AWS console and get a small taste of CI-CD and version control. I however plan to clean up as I embark on the second beginner project and advance into some intermediate stuff. I plan to be more accurate and precise with CICD especially and avoid the mistakes that prompted me to delete my entire workflow folder. I intend to have more control over my architecture making sure my outputs match my inputs and vice versa. 

Future enhancements : As this architectural design gets bigger, it will be nice to work with modules, have separate files as opposed to just one main.tf file with all the code in there. It also will be nice to dive deeper into micro-services as this is a good representation of a monolithic architecture. This could mean using containerisation for building the web server with frameworks like Ruby, Django etc rather than the simple one in this project running this bash script that is supposed to responds to http requests from a user. This design could also utilise modules as this is a more realistic way of working in industry. The design could be broken down into sections and each isolated from the other to avoid any catastrophe if something were to go wrong. There are a lot of future enhancements to be considered but as this was the first of a beginner level project, I shall wrap it up here as I intend to be more thorough with the next one and implement more realistic industry standards. 

How to use this repository : All the code is main.tf under the "code" tab with all changes tracked, history etc. There are also commands for clonning the repository to your local machine if you wish to. Other requests such as pull are possible. See Github documentations on how to navigate a repository. 

