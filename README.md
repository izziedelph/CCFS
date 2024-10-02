Porject Overview: Crawley Caribbean Food Service is a small but increasingly food chain in Crawley West Sussex. It specialises in Caribbean food. They do both restaurant dine-in and deliveries however since it is the only service in the area and there is an increasing number of Caribbean community, the customer demand has grown recently. This spike in demand has prompted the business to move to the cloud. CCFS requires scalable, flexible, and cost-efficient solutions hence the demand for a web-application. They require a reliable, scalable infrastructure to handle fluctuating customer demand especially on weekends, bank holidays and holiday seasons. 

Challenges: The main challenge I encountered was Auto Scaling Groups (ASG) that kept spinning up instances as I had set the minimum to 2. I was keen to incorporate as many concepts to this projects especially Devops CICD piplelines/woprklow with Github actions. At some point I realised that the instances were constantly running due to the automatic trigger in my workflow. Everytime I committed my changes to version control, my workflow.yml file would trigger new instances and this didn’t help as I wanted to clean up resources immediately after verifying that terraform was creating these resources in my AWS console to avoid incurring any charges.  

Approach: Currently i have used EC2 for compute power, servers etc, ELB for high availability (ASG need to exist for ELB application). I plan to add S3 for storage, RDS for database management. The idea is to use terraform to write up the entire infrastructure and see it come to life. I also intend to track commit all changes in version control/Github. 
Solutions 

Lessons learned

Future enhancements 

How to use this repository

