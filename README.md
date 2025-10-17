# Table Of Contents
1. [Overview](#overview)
2. [Features Overview](#features-overview)
3. [Getting Started](#getting-started)
   1. [Server Installation](#server-installation)
      1. [Manual](#manual)
      2. [With Docker (Coming Soon)](#with-docker)
   2. [Client Setup](#client-setup)
4. [Proxy DB Implementations](#proxy-db-implementations)
   1. [Proxy Database Overview](#proxy-database-overview)
   2. [Remote Proxy Database](#remote-proxy-database)
   3. [File Database Proxy](#file-database-proxy)
5. [Features](#features)
   1. [Data Masking](#data-masking)
6. [Advanced Configuration](#advanced-configuration)
   1. [Driver Configuration](#driver-configuration)
   2. [File Database Configuration](#file-database-configuration)
   3. [Client Configuration](#client-configuration)
7. [Technical Support](#technical-support)
8. [Request A New Feature Or File A Bug](#request-a-new-feature-or-file-a-bug)
9. [Discussions And Announcements](#discussions-and-announcements)
10. [End-User License Agreement](#end-user-license-agreement)
11. [Documentation For Older Versions](#documentation-for-older-versions)
    1. [1.1.0](1-1-0/README.md)
    2. [1.0.0](1-0-0/README.md)

# Overview
FlonaDB is an abstraction of a database proxy that allows your application to loosely connect to target databases using 
unique logical names or keys. It differs from a traditional database because it can't be used alone without a 
traditional target database. In fact, you can have multiple applications connect to multiple databases using a single 
centralized configuration and setup.

It also differs from other database proxies because it comes in 2 flavors i.e. it can be deployed with a server side 
application that acts as a reverse proxy and the client application communicates with the remote server over a network 
with SSL. Alternatively, it can be used as a client side 'forward' proxy running inside the same JVM as the client 
applications implying no extra application needs to be deployed. It provides features that are both developer and DevOps 
focused. In forward proxy mode, currently only a File Database Proxy is available i.e. the database connection 
information is managed and read fom a file, this file could be located on a shared volume if you wish. In future 
versions we intend to add other implementations that are managed and read connection information from a database, 
environment variables, secret key manager etc.

FlonaDB effectively becomes a Type 3 JDBC driver when it is deployed in the client-server fashion. 

The database proxy knows about the location of the target databases and any other necessary information needed to 
connect to them e.g. connection URL, username, password etc. There is a lot of possibilities that come to mind if you 
carefully think through all this, you can sandwich a plethora of cool centralized features that are agnostic to the 
target database system between your applications and the target database systems like integrating a custom security 
model result set caching, shared connection pooling, data masking, collecting statistics, connection management and 
monitoring, query timing and logging etc.

Note: Currently, only a JDBC driver is available for FlonaDB. It can be used by any application written with any of 
languages in the Java family. Python users can also use it alongside [this python JDBC adaptor](https://pypi.org/project/JayDeBeApi). 
We will be working on drivers for other languages in the future.

**FlonaDB is available for use for free.**

# Features Overview
Note that all the features below are independent of the target database management system.
- Client applications identify target databases using intuitive unique logical names instead of host name and port.
- Centralized management of target database connection credentials like host name, port, username, password and other 
  required information for multiple applications making it easier to update all applications at once when the connection 
  credentials change, it can be very frustrating to wake up in the morning and a weekly batch processing job which runs 
  at night failed since the application could not connect to the database because the database admin performed a routine 
  update of the passwords during the day.
- Hot reloading of database credentials and configuration properties.
- An added layer of security, currently we support client id and secret key based authentication between the client and 
  proxy server, we intend to add a way to plugin custom authentication and authorization schemes, and to provide 
  features to fetch database user passwords from a secret key manager.
- Database system independence, it means in theory you can swap the target database system without changing client code 
  as long as the client applications are written in such a way that they are agnostic to the target database system 
  behind. And, you can plug in features that cut across all the database systems like collecting statistics, a custom 
  security model, connection timeouts, data masking etc.
- Shared connection pooling between applications.
- Data masking of configured column values both in the client application and the remote server.
- Whitelisting of clients by IP address or subnet.

We're constantly adding new important features to FlonaDB in newer versions.

With the rise of managed databases in cloud, containerization, these features and those to come, bring or will bring 
even more value. We want to believe that in the near future cloud service providers will be charge clients even more 
based of open connections and how much they are used over time therefore, features like a shared connection pool, result 
set caching will help reduce these future costs.

# Getting Started
## Server Installation
Technically speaking, when FlonaDB is deployed to operate over a network, it acts a Type 3 (network) JDBC driver, with 
the server application being the server component and the JDBC driver providing the client component. The server 
application is a standard Spring Boot executable jar that processes database requests from the client driver and sends 
back the responses.

It's worthy noting that the server internally uses FlonaDB again in a 'forward' proxy mode to process client requests 
against target databases via an internal [File Database Proxy](#file-database-proxy) setup.

> [!IMPORTANT]
> It is strongly recommended that the communication between the client the server is done over a secured connection by 
> enabling and setting up SSL on the server.

### With Docker
*Coming Soon....*

### Manual
#### Requirements
- Java 17
- JDBC drivers for the target database systems.

Please use this [server example](examples/server) as a guide.
#### Steps
1. Create an installation directory for your server application.
2. Copy the contents in [server example](examples/server) to your installation directory.
3. [Download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-server&v=1.2.0&e=jar)
   the server jar file and copy it to the installation directory.
4. `db.properties` contains the information that tells the server how to connect to the actual target databases, we're 
   actually configuring the server to internally use one of its own features i.e. a [File Database Proxy](#file-database-proxy) 
   configuration, the file contains the properties below.
    ```properties
    databases=mysql-prod
    
    mysql-prod.url=
    mysql-prod.properties.user=
    mysql-prod.properties.password=
    ```
   We define a target database with `mysql-prod` as its logical name, `mysql-prod.url` takes the value of connection 
   URL, `mysql-prod.properties.user` takes the user password and `mysql-prod.properties.password` takes the user 
   password. You can define more properties to be passed to the driver. For more details, please refer to 
   [File Database Proxy](#file-database-proxy).
5. `clients.properties` contains the client account information, including how they get authenticated and authorized, 
   the file contains the properties below.
    ```properties
    clients=client-one
    
    client-one.secret=secret-one
    client-one.databases=mysql-prod
    ```
   We define a single client account, the client is assigned client id **client-one**, a secret **secret-one** and 
   granted access to a single target databases logically identified as **mysql-prod**. The client will use the client 
   id and secret to authenticate with the server as we will see later. Please refer to
   [Managing Client Accounts](#managing-client-accounts) for more details.
6. `application.properties` is a standard Spring Boot [application properties](https://docs.spring.io/spring-boot/docs/3.1.5/reference/htmlsingle/#appendix.application-properties),
   the file contains the properties below.
   ```properties
   proxy.security.clients.file.path=clients.properties
   ```
   We add a single property named `proxy.security.clients.file.path` with its value set to the path to the clients 
   file we looked at in **Step 5**. Feel free to add other applicable Spring Boot properties.  
7. There is a `drivers` directory in the server example, any required JDBC drivers for the target database systems 
   should be added to this directory, you can change it to a different directory as we will see in the next step. 
8. `flona.sh` is the executable shell script that you should run to start the server,  below,
    ```shell
    export LOADER_PATH=drivers
    export FLONA_FILE_DB_CFG_LOCATION=db.properties
    MAIN_CLASS=com.amiyul.flona.db.remote.server.ServerBootstrap
    SPRING_LAUNCHER=org.springframework.boot.loader.PropertiesLauncher
    # You might have to change the server jar name below to match that of the downloaded file
    java -cp flona-server-1.2.0.jar -Dloader.main=$MAIN_CLASS $SPRING_LAUNCHER
    ```
   This is just a way to run a Spring boot application, on the first line we tell Spring Boot where to load extra jars 
   which in our case will be the JDBC drivers for the target database systems. Be sure to replace 
   `flona-server-1.2.0.jar` with the actual name of the server jar file you downloaded in **Step 3**.

   **Note** that we also export an environment variable with its value set to the location of the `File Database Proxy` 
   we looked at in **Step 4**.
9. Start the server application by navigating to the installation directory from the terminal and run the `flona.sh` 
   script we looked at in **Step 8**, you can stop the server by pressing Ctrl+C for the unix users.

Make sure no errors are reported when the application starts, from the example above, by default the logs are written to 
the console, this is a default behavior from Spring Boot, please refer to [logging config](https://docs.spring.io/spring-boot/docs/3.1.5/reference/htmlsingle/#application-properties.core.logging.config) 
for how you can change the log configuration.

## Client Setup
### Getting FlonaDB Driver
#### Download

You can [download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-driver-single&v=1.2.0&e=jar) 
the single jar file using the download button below and add it to your classpath.

#### Maven

Add the dependency below to your pom file for the driver.
```xml
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-driver-final</artifactId>
    <version>1.2.0</version>
</dependency>
```

### Requirements 
- Flona driver requires Java 17 and above.
- FlonaDB driver jar
- The JDBC drivers for the respective target database systems.

### Driver Configuration (Optional)

If no driver configuration file is provided, the driver will default to a file based proxy database. Otherwise, the path 
to the driver config file can be specified via an environment variable or a JVM system property named 
`FLONA_DRIVER_CFG_LOCATION`, below is an example of the contents of the driver config file.

```properties
config.hot.reload.enabled=true
mask.columns=mysql-prod.person.ssn,mysql-prod.person.birthdate
```

As you can see from the example above, it is a standard Java properties file, `config.hot.reload.enabled` toggles hot 
reloading of the configuration file, please refer to the [Advanced Driver Configuration](#driver-configuration) section 
for the detailed list of supported properties.

### Proxy Database Configuration

As of version 1.1.0, [File Database](#file-database-configuration) is the only proxy DB implementation therefore it is 
the one we are going to use in all our examples.

The path to the database config file can be specified via an environment variable or a JVM system property named 
`FLONA_FILE_DB_CFG_LOCATION`, below is an example of the contents of the database config file.

```properties
databases=mysql-prod,postgresql-research

mysql-prod.url=jdbc:mysql://localhost:3306/prod
mysql-prod.properties.user=mysql-user
mysql-prod.properties.password=mysql-pass

postgresql-research.url=jdbc:postgresql://localhost:5432/research
postgresql-research.properties.user=postgresql-user
postgresql-research.properties.password=postgresql-pass
```
The `databases` property takes a comma-separated list of the unique logical names of the target databases, then we
define connection properties for each target database, the properties for each target database must be prefixed with
database name that was defined in the value of the `databases` property as seen in the example above, please refer to
the [File Database Configuration](#file-database-configuration) section for the detailed list of supported properties.

### Connecting To The Database
Make sure you have done the following below,

- Added to your application's classpath the Flona DB and the drivers for your target database system.
- Configured the location of the [file based database](#file-database-configuration) config file

#### Obtaining a connection:

```java
Connection c = DriverManager.getConnection("jdbc:flona://mysql-prod"); 
```

The URL above is used to connect to a target database named `mysql-prod` defined in the proxy database config file we 
created.

#### Obtaining a connection using Flona data source:

Flona driver also provides `com.amiyul.flona.driver FlonaDataSource` which is a JDBC `DataSource` implementation and 
below is an example demonstrating how to use it to obtain a connection to a target database named `mysql-prod`.

```java
FlonaDataSource ds = new FlonaDataSource();
ds.setTargetDatabaseName("mysql-prod");
Connection c = ds.getConnection();

```

# Proxy DB Implementations
## Proxy Database Overview
FlonaDB database implementations are simple but powerful abstractions of a database proxy, depending on the
implementation, the proxy mechanism can be run 100% within the client application or partially with the other component
running on a remote server. The proxy knows the locations and any other necessary information needed to connect to the
databases.

You can use a single shared configuration file in order to manage the configurations in a single place. E.g. you could
store the file on a shared drive that is accessed by all applications using Flona, this approach would typically apply
to distributed systems with multiple nodes to centralize the management of the database credentials used by all the
nodes.

As of version 1.1.0, [File Database Proxy](#file-database-proxy) is the only available implementation, it is a local implementation
meaning both the driver and proxy DB are configured and run in the same JVM as the application, it implies you need to
add both the Flona driver and any necessary target DB driver(s) to your application's the classpath, more
implementations will be added in future versions.

## Remote Proxy Database

## File Database Proxy
A proxy database implementation that is configured in a file, it is 100% client side and runs inside the same JVM as the 
client application.

The location of the config file can be specified via an environment variable or a JVM system property named 
`FLONA_FILE_DB_CFG_LOCATION`, below is an example of the contents of the config file.

```properties
databases=mysql-prod,postgresql-research

mysql-prod.url=jdbc:mysql://localhost:3306/prod
mysql-prod.properties.user=mysql-user
mysql-prod.properties.password=mysql-pass

postgresql-research.url=jdbc:postgresql://localhost:5432/research
postgresql-research.properties.user=postgresql-user
postgresql-research.properties.password=postgresql-pass
```

The `databases` property takes a comma-separated list of the unique names of the target databases, then we define 
connection properties for each target database, the properties for each target database must be prefixed with database 
name that was defined in the value of the `databases` property as seen in the example above, please refer to the 
[File Database Configuration](#file-database-configuration) section for the detailed list of supported properties.

# Features
## Data Masking
Different database systems provide functions that can be used in queries to mask values in a result set but these 
functions are database specific and used in individual queries.

FlonaDB provides a database independent masking feature at the application level which allows developers to externally 
configure column whose values should be masked in result sets, the masking rules are applied to all applicable result 
set values. Currently, the masking is only applicable to columns of data types that map to String class in Java.

### String Mask Modes

A mask mode specifies the masking behavior or rules applied to column values. If no mode is specified, by default a mask 
of random length is generated, with the length being at least 2 unless the column length in the database is set to 1, 
also the generated mask won't exceed the database column length. Below are the supported modes.

1. **Head**: A specific number of characters in the string are masked counting from the head. If no number to mask is 
   specified, by default all the characters are masked except the last.
2. **Tail**: A specific number of characters in the string are masked counting from the tail. If no number to mask is 
   specified, by default all the characters are masked except the first.
3. **Regex**: Masking is performed by applying a regex to the original value to mask specific characters.
4. **Indices**: A list of indices is provided for the characters to mask.

### Mask Configuration
Mask configurations are defined in the driver config file mentioned in the Quick Start section, below is a mask 
configuration example.
```properties
mask.columns=prod.sales.location.name, sales.person.birthdate, marketing.person.ssn

mask.prod.sales.location.name.mode=tail

mask.sales.person.birthdate.mode=regex
mask.sales.person.birthdate.regex=[A-Za-z]

mask.marketing.person.ssn.mode=indices
mask.marketing.person.ssn.indices=0,1,2,4,5
```
In the above example, we have used the `mask.columns` property to configured 3 column whose values should be masked, the 
value is a comma separated list of full column names i.e. including owning table, schema and/or catalog, note that 
schema and catalog are implemented differently by different database vendors so be sure that you define them based on 
the target database system, a period is used to separate the components of full column name i.e. column, table, schema 
and catalog name. The first definition is for the `name` column in the `location` table in the `sales` schema in the 
`prod` catalog, the second definition is for the `birthdate` column in the `person` table in the `sales` schema or 
catalog, and the third definition is for the `ssn` column in the `person` table in the `marketing` schema or catalog.

Please pay attention to the naming of the other set of properties, they are used to configure the masking rules for each 
column, each of them is prefixed with `mask`. and the same full column name as that used in the `mask.columns` property 
value.

With the above mask configuration when your application executes a query that returns a result set containing values 
from the above columns, a location name like Kampala will be masked to K******, a person birthdate like 01-Nov-1986 will 
be masked to 01-***-1986 and a person SSN like 111-22-3333 will be masked to ***-\*\*-3333.

For full mask configuration details, please refer to the [Advanced Driver Configuration](#driver-configuration) section.

**Note**

- Masking is not applied to null values.
- Masking does not work in some cases depending on how the developer writes the query, e.g. queries with masked column 
names wrapped inside SQL functions, take an example of the query below to be run against MySQL.
  ```
  SELECT lower(name) FROM location;
  ```
  Masking won't work for the name column in the query above.
- As noted above, it's evident that the masking feature is not really a security feature to be used by system admins to 
mask values from developers, but rather a security feature intended for developers to mask values from users of the 
user-facing application.


# Advanced Configuration
## Driver Configuration
The path to the driver config file can be specified via an environment variable or a JVM system property named 
`FLONA_DRIVER_CFG_LOCATION`.

**Note:** Property names containing `FULL_COLUMN_NAME` apply to column masking definitions, it is a placeholder and must be 
replaced with the full column name, implying the values for those properties only apply to a single column mask 
definition. To understand what a full column name means, please refer to the [Data Masking](#data-masking) section.

| Name | Description |  Required  |  Default Value  |
|------|-------------|:----------:|:---------------:|
|config.hot.reload.enabled|When set to true, hot reloading of the driver config file is enabled, all the properties values are reloaded when modified except this property's value itself, implying that the value of this property only takes effect at application startup.|No|false|
|mask.columns|Specifies a comma-separated list of full column names in result sets whose values should be masked.|No||
|mask.FULL_COLUMN_NAME.mode|Specifies the masking mode to apply to the column matching the full column name.|No||
|mask.FULL_COLUMN_NAME.number|Specifies the number of characters to mask counting from one end of the string, this property only applies to mask definitions where mode is set to `head` or `tail`.|No||
|mask.FULL_COLUMN_NAME.regex|Specifies the regex to apply when masking column values, this property only applies to mask definitions where mode is set to `regex` and is required for this mode.|No||
|mask.FULL_COLUMN_NAME.indices|Specifies the indices of the characters to mask in column values, this property only applies to mask definitions where mode is set to `indices` and is required for this mode.|No||

## File Database Configuration
The path to the database config file can be specified via an environment variable or a JVM system property named 
`FLONA_FILE_DB_CFG_LOCATION`, below is an example of the contents of the database config file.

**Note:** `TARGET_DB_NAME` is a placeholder where it exists in a property name and must be replaced with the target 
database name, implying the values for those properties only apply to a single target database.

| Name | Description | Required | Default Value |
|------|-------------|:--------:|:-------------:|
|databases| A comma-separated list of the unique names of the target databases.|Yes||
|TARGET_DB_NAME.url|The URL of the database to which to connect.|Yes||
|TARGET_DB_NAME.properties.user|The user to use to connect to the database.|No||
|TARGET_DB_NAME.properties.password|The user password to use to connect to the database.|No||

## Client Configuration

# Technical Support
For more details about FlonaDB and technical support, please reach out to us via our [contact us](https://amiyul.com/contact-us) 
page.

# Request A New Feature Or File A Bug
Please see [here](https://github.com/flonadb/flonadb/issues)

# Discussions And Announcements
Please see [here](https://github.com/flonadb/flonadb/discussions)

# End-User License Agreement
See [End-User License Agreement](https://amiyul.com/flonadb-eula)

# Documentation For Older Versions
- [1.1.0](1-1-0/README.md)
- [1.0.0](1-0-0/README.md)
