Below are some of the things that motivated us to create this tool.

- We were working on a project and needed a tool like Flona but the only available ones we could identify as close were 
commercial, the lack of a free alternative drove us to set out and create our own.
- With the rise of many client side and middleware technologies providing features that cut across different database
  systems and applications e.g. connection pooling, caching, load balancing, failover, connection timeout, transaction
  isolation, using secret managers to store database credentials, user access management etc. There is a growing list of
  aspects you need to duplicate through configuration and installation and in a decentralized way, we strongly believe
  tools like Flona are stepping up to provide a rather centralized approach that is database agnostic e.g. for an
  organization or department.
- Also, with the rise of managed databases in the cloud, containerization, these features and those to come, bring or 
will bring even more value. We want to believe that in the near future cloud service providers will charge clients even 
more based of open connections and how much they are used over time therefore, features like a shared connection pool, 
result set caching will help reduce these future costs. Plus, you should be able to switch service providers and 
containers which usually means IP addresses, user accounts, passwords change and not have to reconfigure and restart all 
client applications.
- I have seen companies that needed to give access to their databases to third parties like researchers, partners, 
subsidiaries, regulatory bodies, it could also be just sharing databases between different autonomous departments 
within the same company. One should be able to just grant and revoke their access to the Flona server which would 
effectively grant or revoke their access to the target database instances.
- If you had a high availability application that runs a batch job every 2 hours, the job is the only component that 
requires access to a specific database instance and the database password is rotated, the devops team receives a 
notification 1hr before the next run with the new password, surely it would be great if they had the option to update 
the password in the config file without bringing down the entire application.
