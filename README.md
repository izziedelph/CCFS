Porject Overview: Crawley Caribbean Food Service is a small but increasingly food chain in Crawley West Sussex. It specialises in Caribbean food. They do both restaurant dine-in and deliveries however since it is the only service in the area and there is an increasing number of Caribbean community, the customer demand has grown recently. This spike in demand has prompted the business to move to the cloud. CCFS requires scalable, flexible, and cost-efficient solutions hence the demand for a web-application. They require a reliable, scalable infrastructure to handle fluctuating customer demand especially on weekends, bank holidays and holiday seasons. 

Challenges: The main challenge I encountered was Auto Scaling Groups (ASG) that kept spinning up instances as I had set the minimum to 2. I was keen to incorporate as many concepts to this projects especially Devops CICD piplelines/woprklow with Github actions. At some point I realised that the instances were constantly running due to the automatic trigger in my workflow. Everytime I committed my changes to version control, my workflow.yml file would trigger new instances and this didn’t help as I wanted to clean up resources immediately after verifying that terraform was creating these resources in my AWS console to avoid incurring any charges.  

Approach: Currently I have used EC2 for compute power, servers etc, ELB for high availability (ASG need to exist for ELB application). I plan to add S3 for storage, RDS for database management. The idea is to use terraform to write up the entire infrastructure and see it come to life. I also intend to track, commit all changes in some form of version control/Github. 

Solutions: Even if I was keen to incorporate as many cloud practices as possible, Iac, CICD etc my initial attempt at using Github actions to create a workflow failed. My first mistake was adding terraform apply to the workflow which I then removed and only allowed the workflow to run terraform plan. This was to avoid the constant spinning up of instances due to ASG (min=2 max=10). I preferred spinning up these instances or runnning terraform apply locally in my mac Terminal. For some reason I cannot explain, this did not work and every time I updated my main.tf file, and committed the changes to Github, my workflow continued spinning up instances. I also tried running terraform destroy manually with a separate .yml file specially for this reason. This only worked once and I was still unable to conveniently have control over these instances and delete them when I wanted. I had to eventually settle with deleting my workflow folder in my CCFS repository which had both CICD.yml and destroy.yml files in it.  

Lessons learned

Future enhancements 

How to use this repository

