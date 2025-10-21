<h1 style="color: maroon">Flona Documentation</h1>

## Table Of Contents
1. [Overview](#overview)
2. [Motivation](motivation/README.md)
3. [Features Overview](#features-overview)
4. [Getting Started](#getting-started)
   1. [Server Installation](#server-installation)
      1. [Manual (With Example)](#manual)
      2. [With Docker (Coming Soon)](#with-docker)
   2. [Client Setup](#client-setup)
5. [Proxy Database Implementations](#proxy-database-implementations)
   1. [Proxy Overview](#proxy-database-overview)
   2. [Remote](#remote-proxy-database)
   3. [File](#file-proxy-database)
6. [Features](#features)
   1. [Connection Pooling](#connection-pooling)
   2. [Runtime Configuration Reload](#runtime-configuration-reload)
   3. [Data Masking](#data-masking)
7. [Configuration](#configuration)
   1. [Server](#server-configuration)
   2. [Remote Proxy Database](#remote-proxy-database-configuration)
   3. [File Proxy Database](#file-proxy-database-configuration)
   4. [Driver](#driver-configuration)
   5. [Connection Pooling](#connection-pooling-configuration)
8. [Technical Support](#technical-support)
9. [Request A New Feature Or File A Bug](#request-a-new-feature-or-file-a-bug)
10. [Discussions And Announcements](#discussions-and-announcements)
11. [End-User License Agreement](#end-user-license-agreement)
12. [Documentation For Older Versions](#documentation-for-older-versions)
    1. [1.1.0](1-1-0/README.md)
    2. [1.0.0](1-0-0/README.md)

# Overview
Flona is a free abstraction of a database proxy that allows your application to loosely connect to target database 
instances using unique logical names or keys. It differs from a traditional database because it can't be used alone 
without a traditional target database instance. In fact, you can have multiple applications connect to multiple database 
instances using a single centralized configuration and setup.

It also differs from other database proxies because it comes in 2 flavors i.e. it can be deployed with a server side 
application that acts as a reverse proxy and the client application communicates with the remote server over a network 
with SSL. Alternatively, it can be used as a client side 'forward' proxy running inside the same JVM as the client 
applications implying no extra application needs to be deployed. It provides features that are both developer and DevOps 
focused. In forward proxy mode, currently only a File Proxy Database is available i.e. the database connection 
information is managed and read fom a file, this file could be located on a shared volume if you wish. In future 
versions we intend to add other implementations that are managed and read connection information from a database, 
environment variables, secret key manager etc.

Flona effectively becomes a Type 3 JDBC driver when it is deployed in the client-server fashion. 

The database proxy knows about the location of the database instances and any other necessary information needed to 
connect to them e.g. connection URL, username, password etc. There is a lot of possibilities that come to mind if you 
carefully think through all this, you can sandwich a plethora of cool centralized features that are agnostic to the 
database systems between your applications and the database instances like integrating a custom security model result 
set caching, shared connection pooling, data masking, collecting metrics, connection management and monitoring, query 
timing and logging etc.

Note: Currently, only a JDBC driver is available for Flona. It can be used by any application written with any of 
languages in the Java family. Python users can also use it via 
[this python JDBC adaptor](https://pypi.org/project/JayDeBeApi). We will be working on drivers for other languages in 
the future.

**Flona is available for use for free.**

# Features Overview
Note that all the features below are independent of the target database management system.
- Client applications identify database instances using intuitive unique logical names instead of host name and port.
- Centralized management of database instance connection credentials like host name, port, username, password and other 
  required information for multiple applications making it easier to update all applications at once when the connection 
  credentials change. It also means you can rotate databases credentials in the proxy more frequently while you rarely 
  rotate of those of the client applications which minimizes downtime.
- Hot reloading of database credentials and configuration properties.
- An added layer of security, as of version 1.2.0, only client id and secret key based authentication is supported 
between the client and proxy server, we intend to add a way to plug in custom authentication and authorization schemes 
and to provide other features e.g. to retrieve client secrets and database user passwords from a secret key manager.
- Database system independence, it means in theory you can swap the target database system without changing client code 
  as long as the client applications are written in such a way that they are agnostic to the target database system 
  behind. And, you can plug in features that cut across all the database systems like collecting metrics, a custom 
  security model, connection timeouts, data masking etc.
- Shared connection pooling between applications, a feature that can greatly minimise the number of open physical 
  connections to the target database instances.
- Data masking of configured column values both in the client application and the remote server.
- Whitelisting of clients by IP address or subnet.

We're constantly adding new important features to Flona in newer versions.

# Getting Started
## Server Installation
Technically speaking, when Flona is deployed to operate over a network, it acts a Type 3 (network) JDBC driver, with 
the server application being the server component and the JDBC driver providing the client component. The server 
application is a standard Spring Boot executable jar that processes database requests from the client driver and sends 
back the responses.

It's worthy noting that the server internally uses Flona again in a 'forward' proxy mode to process client requests 
against a target database instance via an internal [File Proxy Database](#file-proxy-database) setup.

> [!IMPORTANT]
> It is strongly recommended that the communication between the client the server is done over a secured connection by 
> enabling and setting up SSL on the server.

### Requirements
- Java 17
- JDBC drivers for the target database systems.

### With Docker
*Coming Soon....*

### Manual

Please use this [server example](examples/server) as a guide.
#### Steps
1. Create an installation directory for your server application.
2. [Download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-server&v=1.2.0&e=jar)
   the server jar file and copy it to the installation directory.
3. Copy the contents of [server example](examples/server) to your installation directory and in the next steps we will 
   go over the role of each file while explaining the contents.
4. `db.properties` contains the information that tells the server how to connect to the actual database instances, we're 
   actually configuring the server to internally use one of its own features i.e. a 
   [File Proxy Database](#file-proxy-database), the example file contains the properties below.
    ```properties
    # Logical name to identify the available database instances
    db.instances=mysql-prod
    
    # Connection URL for the mysql-prod database instance
    mysql-prod.url=
    
    # Username to use to connection to the mysql-prod database instance
    mysql-prod.properties.user=
    
    # Password to use to connection to the mysql-prod database instance
    mysql-prod.properties.password=
    ```
   We define a database instance with `mysql-prod` as its logical name, `mysql-prod.url` takes the value of connection 
   URL, `mysql-prod.properties.user` takes the user password and `mysql-prod.properties.password` takes the user 
   password. You can define more properties to be passed to the driver. This is actually similar to how you define 
   multiple data sources in a Spring Boot application, an application server like Jboss or a servlet container like 
   Tomcat, but in all these cases the data source information is generally not dynamically reloadable at runtime but 
   Flona supports this feature without requiring a client application or Flona server restart. For more details, please 
   refer to [File Proxy Database](#file-proxy-database) documentation.
5. `clients.properties` contains the client account information, including how they get authenticated and authorized, 
   the example file contains the properties below.
    ```properties
    # You can define more client ids, multiple client ids are separated by a comma
    clients=client-one
    
    # Specifies the secret for client-one and the client will use the key-value pair below
    # to authenticate with our server
    client-one.secret=secret-one
   
    # Grants client-one access to a database instance logically named mysql-prod, you can grant
    # the client access to more instances, multiple instance names are separated by a comma
    client-one.db.instances=mysql-prod
    ```
   We define a single client account, the client is assigned id `client-one`, a secret `secret-one` and granted access 
   to a single database instance logically identified as `mysql-prod`. In later steps, we will see how the server is 
   configured to locate this file. In the [client setup](#client-setup), we will also see how the clients are configured 
   to use the client id and secret to authenticate with the server.
6. `application.properties` is a standard Spring Boot [application properties](https://docs.spring.io/spring-boot/docs/3.1.5/reference/htmlsingle/#appendix.application-properties),
   the example file contains the properties below.
   ```properties
   flona.security.clients.file.path=clients.properties
   ```
   We add a single property named `flona.security.clients.file.path` with its value set to the path of the clients 
   file we looked at in **Step 5**. Please refer to [Server Configuration](#server-configuration) for more 
   details, also feel free to add other applicable Spring Boot properties. 
7. Create a new directory named `drivers` in the installation directory, any required JDBC drivers for the target 
   database systems should be added to this directory, you can change it to a different directory as we will see in the 
   next step. 
8. `flona.sh` is the executable shell script that you should run to start the server, below are the contents.
    ```shell
    # Add the JDBC drivers to this directory
    export LOADER_PATH=drivers
    export FLONA_FILE_DB_CFG_LOCATION=db.properties
    MAIN_CLASS=com.amiyul.flona.db.remote.server.ServerBootstrap
    SPRING_LAUNCHER=org.springframework.boot.loader.PropertiesLauncher
    # You might have to change the server jar name below to match that of the downloaded file
    java -cp flona-server-1.2.0.jar -Dloader.main=$MAIN_CLASS $SPRING_LAUNCHER
    ```
   This is just a way to run a Spring boot application, we export an environment variable `LOADER_PATH` with a value of 
   `drivers` which is the path to directory we saw earlier where to load extra jars which in our case will be the JDBC 
   drivers for the target database systems. We also define another environment variable `FLONA_FILE_DB_CFG_LOCATION` 
   with a value of `db.properties` which is the path to the `File Proxy Database` file we looked at in **Step 4**.

   **Note** Remember to replace `flona-server-1.2.0.jar` with the actual name of the server jar file you downloaded in 
   **Step 2**.
9. Start the server application by navigating to the installation directory from the terminal and run the `flona.sh` 
   script we looked at in **Step 8**, you can stop the server by pressing Ctrl+C for the unix users.

Make sure no errors are reported when the application starts, from the example above, by default the logs are written to 
the console, this is a default behavior from Spring Boot, please refer to [logging config](https://docs.spring.io/spring-boot/docs/3.1.5/reference/htmlsingle/#application-properties.core.logging.config) 
for how you can change the log configuration.

## Client Setup
### Getting Flona Driver
#### Download

You can [download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-driver-single&v=1.2.0&e=jar) 
the single jar file using the download button below and add it to your application's classpath.

#### Maven

Add the dependencies below to your pom file for the driver.
```xml
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-driver-final</artifactId>
    <version>1.2.0</version>
</dependency>
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-driver-ext-final</artifactId>
    <version>1.2.0</version>
</dependency>
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-db-ext-final</artifactId>
    <version>1.2.0</version>
</dependency>
```

TODO describe the 3 dependencies above.

### Requirements 
- Java 17.
- Flona JDBC driver

> [!NOTE]
> No JDBC drivers for the target database systems are required when using Flona in a reverse proxy mode i.e. with a 
> [Remote Proxy Database](#remote-proxy-database).

### Driver Setup
Create a new properties file with the contents below, in our example we will name it `flona-driver.properties`
`FLONA_DRIVER_CFG_LOCATION`, below is an example of the contents of the driver config file.
```properties
# Specifies the name of the proxy database provider to use, 
# possible values are file and remote, defaults to file.
db.provider=remote

# Specifies the host name of the server application.
proxy.remote.server.host=localhost

# Specifies the port of the server application, defaults to 8825. 
#proxy.remote.server.port=

# When set to true, it disables SSL otherwise it is enabled.
proxy.remote.ssl.disabled=true

# The client id of the client to use to authenticate with the server.
proxy.remote.client.id=client-one

# The secret of the client to use to authenticate with the server.
proxy.remote.client.secret=secret-one
```
From the example above, we have configured the client component of the Flona JDBC driver to connect to the server 
application we installed earlier. Carefully read the inline comments above each property. Please refer to the 
[Remote Proxy Database Configuration](#remote-proxy-database-configuration) section for the detailed list of supported 
properties.

The path to the created driver configuration file above is passed to the client application via an environment 
variable or a JVM system property named `FLONA_DRIVER_CFG_LOCATION`.

> [!TIP]
> You could possibly host the above configuration file on shared volume among nodes of a clustered application.

### Obtaining A Connection
Make sure you have done the following below,
- Added to your application's classpath the Flona.
- Configured the location of the [Driver Configuration](#driver-configuration) file.

#### Using DriverManager
```java
Connection c = DriverManager.getConnection("jdbc:flona://mysql-prod"); 
```
The URL above is used to connect to a database instance named `mysql-prod` defined in the proxy database config file we 
created.

#### Using FlonaDataSource
Flona driver also provides `com.amiyul.flona.driver FlonaDataSource` which is a JDBC `DataSource` implementation and 
below is an example demonstrating how to use it to obtain a connection to a database instance named `mysql-prod`.
```java
FlonaDataSource ds = new FlonaDataSource();
ds.setDatabaseInstance("mysql-prod");
Connection c = ds.getConnection();

```
# Proxy Database Implementations
## Proxy Database Overview
Flona proxy database implementations are simple but powerful abstractions of a database proxy, depending on the
implementation, the proxy mechanism can be run 100% within the client application or partially with the other component
running on a remote server. The proxy knows about available database instances and the necessary information needed to 
connect to each of them.

You can choose to use a single shared configuration file in order to manage the configurations in a single place. E.g. 
you could store the file on a shared drive that is accessed by all applications using Flona, this approach would 
typically apply to distributed or clustered systems with multiple nodes to centralize the management of the database 
credentials used by all the nodes.

As of version 1.2.0, there is only 2 proxy implementations i.e. [Remote Proxy Database](#remote-proxy-database) and 
[File Proxy Database](#file-proxy-database), more implementations will be added in future versions.
## Remote Proxy Database
This is a Type 3 JDBC driver implementation of proxy database, the driver comes in form of 2 components, a client JDBC 
driver component which communicates with the server component over a network to process database calls made by the 
client application. The server component is a TCP/IP server embedded inside a Spring Boot application. The database 
instance definitions are maintained on the Flona server and clients only need to know how to connect to the server and 
pass to it the logical names of the database instances they want to connect to and use.

**Note** No JDBC drivers have to be added to the classpath of the client application with this proxy, they are only 
added to the server.

To use a remote proxy database, you need to do the following,
- [Install the Flona server](#server-installation).
- [Configure the client application](#client-setup) by setting the value of the `db.provider` property to 
`remote` in the [Driver Configuration](#driver-configuration)

## File Proxy Database
This is a proxy database implementation that reads the database instance definitions from a file, it is 100% client side 
and runs inside the same JVM as the client application, it requires adding the required JDBC drivers to the classpath of 
the client application.

To use a file proxy database, you need to do the following,
- Create a database instance definition file that defines the database instance logical names and any necessary 
information required to connection each of them i.e. the connection URL, username and password. Below is an example of 
the contents of the instance definition file.
    ```properties
    db.instances=mysql-prod,postgresql-research
    
    mysql-prod.url=jdbc:mysql://localhost:3306/prod
    mysql-prod.properties.user=mysql-user
    mysql-prod.properties.password=mysql-pass
    
    postgresql-research.url=jdbc:postgresql://localhost:5432/research
    postgresql-research.properties.user=postgresql-user
    postgresql-research.properties.password=postgresql-pass
    ```
    The `databases` property takes a comma-separated list of the unique names of the database instances, then we define 
    connection properties for each database instance, the properties for each instance must be prefixed with the 
    name that was defined in the value of the `databases` property as seen in the example above, please refer to the 
    [File Proxy Database Configuration](#file-proxy-database-configuration) section for the complete list and 
    documentation of each property.
- [Configure the client application](#client-setup) by setting the value of the `db.provider` property to
`file` in the [Driver Configuration](#driver-configuration). Alternatively, you can comment out this property since 
`file` is the default value.
- You also need to tell the Flona driver the location of database instance definition file, this is done by setting the 
path to the file as the value of an environment variable or a JVM system property named `FLONA_FILE_DB_CFG_LOCATION`.

> [!NOTE]
> The File Proxy Database supports runtime reloading of the database instance definition file, to enable this see 
> [File Proxy Database Configuration](#file-proxy-database-configuration) 

# Features
## Connection Pooling
TODO Document minimizing of open connections
## Runtime Configuration Reload
TODO Explain use cases of this
## Data Masking
Different database systems provide functions that can be used in queries to mask values in a result set but these 
functions are database specific and used in individual queries.

Flona provides a database independent masking feature at the application level which allows developers to externally 
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
Mask configurations are defined in the [Advanced Driver Configuration](#driver-configuration), below is a mask 
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


# Configuration
## Server Configuration
The Flona Server is TCP/IP server embedded inside a Spring Boot application, so any applicable Spring Boot [application property](https://docs.spring.io/spring-boot/docs/3.1.5/reference/htmlsingle/#appendix.application-properties)
can set used. The table below documents all the custom driver properties the server application exposes.

| Name | Description                                                                                                                                                                                       | Required | Default Value |
|------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------:|:-------------:|
|flona.server.port| The port the server should Listen on for client requests.                                                                                                                                         |    NO    |     8825      |
|flona.server.thread.count| The number of threads the server should use to concurrently process client requests.                                                                                                              |    NO    |      16       |
|flona.network.backlog.max.size| Sets the TCP backlog size for the server.                                                                                                                                                         |    NO    |      128      |
|flona.network.allowed.ip.list| Comma separated list of the client IP addresses and Subnets to accept e.g. `100.63.89.1, 99.63.144.0/21`, leave blank to allow all.                                                               |    NO    |               |
|flona.ssl.disabled| Toggles the use of SSL for connections between the client and the server, a value of true disables SSL otherwise it is enabled, defaults to false. It is **strongly** discouraged to disable SSL. |    NO    |     false     |
|flona.ssl.keystore.file.path| The path to the keystore containing the server certificate, **required** when SSL is enabled.                                                                                                     |    NO    |               |
|flona.ssl.keystore.password| The password for the keystore containing the server certificate, **required** when SSL is enabled.                                                                                                |    NO    |               |
|flona.ssl.keystore.type| The type of the keystore containing the server certificate.                                                                                                                                       |    NO    |               |
|flona.ssl.keystore.algorithm| Specifies the name of key manager factory algorithm.                                                                                                                                              |    NO    |               |
|flona.ssl.supported.versions| Comma separated list of the supported SSL versions e.g. `TLSv1.2,TLSv1.3`.                                                                                                                        |    NO    |               |
|flona.security.clients.file.path| The path to the file containing the client account configurations.                                                                                                                                |   Yes    |               |

## Remote Proxy Database Configuration
The [Remote Proxy Database](#remote-proxy-database) uses a client-server architecture, it means the client application 
only needs to know how to connect to the Flona server and the logical names of the database instances to use, the client 
does not need to know the details of how to connect to the targets themselves. The required details of how the client 
connects to the server are directly defined in the [Driver Configuration](#driver-configuration) file, the table below 
documents all the extra driver properties the remote proxy exposes.

| Name | Description                                                                                                                                                                                                                                           | Required | Default Value |
|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------:|:-------------:|
|proxy.remote.server.host| The host name to use to connect to the Flona server application.                                                                                                                                                                                      |   Yes    |               |
|proxy.remote.server.port| The port number to use to connect to the Flona server application.                                                                                                                                                                                    |    No    |     8825      |
|proxy.remote.client.id| The client id to use for authentication.                                                                                                                                                                                                              |   Yes    |               |
|proxy.remote.client.secret| The client secret to use for authentication.                                                                                                                                                                                                          |   Yes    |               |
|proxy.remote.ssl.disabled| Toggles the use of SSL for connections between the client and the server, a value of true disables SSL otherwise it is enabled, defaults to false. It is **strongly** discouraged to disable SSL.                                                     |    No    |     false     |
|proxy.remote.ssl.truststore.file.path| The path to the certificate trust store to use, **required** when SSL is enabled.                                                                                                                                                                     |    No    |               |
|proxy.remote.ssl.truststore.password| The password for the certificate trust store, **required** when SSL is enabled.                                                                                                                                                                       |    No    |               |
|proxy.remote.ssl.truststore.type| The type of the certificate trust store.                                                                                                                                                                                                              |    No    |               |
|proxy.remote.ssl.truststore.algorithm| Specifies the name of trust manager factory algorithm.                                                                                                                                                                                                |    No    |               |
|proxy.remote.ssl.supported.versions| Comma separated list of the supported SSL versions e.g. `TLSv1.2,TLSv1.3`. These must be among those supported by the server.                                                                                                                         |    No    |               |
|proxy.remote.bounded.requests.no-op| Currently, the remote proxy database does not support calls to `Connection.beginRequest()` and `Connection.endRequest()`, when set to true Flona will silently ignore the calls otherwise to will throw a `java.sql.SQLFeatureNotSupportedException`. |    No    |     false     |

## File Proxy Database Configuration
The [File Proxy Database](#file-proxy-database) reads the database instance definitions from a file, the path to this 
file can be specified via an environment variable or a JVM system property named`FLONA_FILE_DB_CFG_LOCATION`, the table 
below documents all the properties that can be defined in a database instance definition file where `TARGET_DB_NAME` is 
a placeholder where it exists in a property name and must be replaced with the target database instance name, implying 
the values for those properties only apply to a single instance.

| Name | Description                                                                 | Required | Default Value |
|------|-----------------------------------------------------------------------------|:--------:|:-------------:|
|databases| A comma-separated list of the unique names of the database instances. |Yes||
|TARGET_DB_NAME.url| The URL of the database to which to connect.                                |Yes||
|TARGET_DB_NAME.properties.user| The user to use to connect to the database.                                 |No||
|TARGET_DB_NAME.properties.password| The user password to use to connect to the database.                        |No||

## Driver Configuration
The path to the driver config file can be specified via an environment variable or a JVM system property named 
`FLONA_DRIVER_CFG_LOCATION`.

**Note:** Property names containing `FULL_COLUMN_NAME` apply to column masking definitions, it is a placeholder and must
be replaced with the full column name, implying the values for those properties only apply to a single column mask 
definition. To understand what a full column name means, please refer to the [Data Masking](#data-masking) section.

| Name | Description                                                                                                                                                                                                                                                       |  Required  |  Default Value  |
|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------:|:---------------:|
|config.hot.reload.enabled| When set to true, hot reloading of the driver config file is enabled, all the properties values are reloaded when modified except this property's value itself, implying that the value of this property only takes effect at application startup.                |No|false|
|mask.columns| Specifies a comma-separated list of full column names in result sets whose values should be masked.                                                                                                                                                               |No||
|mask.FULL_COLUMN_NAME.mode| Specifies the masking mode to apply to the column matching the full column name.                                                                                                                                                                                  |No||
|mask.FULL_COLUMN_NAME.number| Specifies the number of characters to mask counting from one end of the string, this property only applies to mask definitions where mode is set to `head` or `tail`.                                                                                             |No||
|mask.FULL_COLUMN_NAME.regex| Specifies the regex to apply when masking column values, this property only applies to mask definitions where mode is set to `regex` and is required for this mode.                                                                                               |No||
|mask.FULL_COLUMN_NAME.indices| Specifies the indices of the characters to mask in column values, this property only applies to mask definitions where mode is set to `indices` and is required for this mode.                                                                                    |No||
|lazy.connections.enabled| (**ONLY supported by** [Remote Proxy Database](#remote-proxy-database)) Turns on a feature where the proxy database delays obtaining a physical connection to the Flona server until the first call that requires a trip to the server is made, default to false. |No|false|

## Connection Pooling Configuration
Flona comes with built-in connection pooling support with 2 possible providers you can select from i.e. 
[HikariCP](https://github.com/brettwooldridge/HikariCP) and [c3p0](#https://www.mchange.com/projects/c3p0/).

The pooling behavior is configured in the [driver configuration](#driver-configuration) file, it is disabled 
by default. It can be enabled by setting the value of the property named `pooling.provider.name`, possible values are `hikari` 
and `c3p0`. It is also automatically enabled when any provider pooling property is set globally, in this case the 
pooling provider is inferred from any of the configured pooling properties themselves. For instance, if your driver 
config contains a property named `pooling.c3p0.maxPoolSize`, then the c3p0 provider is auto selected. You **cannot** add 
properties for both providers in the same config file otherwise it will be rejected. Pooling properties 
can be defined globally for all database instance and can be overridden one by one for a specific target database instance using the formats below
- `pooling.PROVIDER_NAME.PROPERTY_NAME` are provider specific where `PROVIDER_NAME` is a placeholder for 
the pooling provider name and `PROPERTY_NAME` is the provider specific pooling property name. For example, if you wish 
to set the maximum pool size, for HikariCP the full property name would be `pooling.hikari.maximumPoolSize` and for c3p0 
the full property name would be `pooling.c3p0.maxPoolSize`.
- `pooling.DB_INSTANCE_NAME.PROPERTY_NAME` are properties applied to a data source of a single target database instance 
where `DB_INSTANCE_NAME` is the database instance name and `PROPERTY_NAME` is the property name. For example, if you 
want to set the maximum pool size for a database instance named `mysql-prod` and, you are using c3p0 as the provider, 
the full property name would be `pooling.mysql-prod.maxPoolSize`. These values take precedence over 
similar ones set globally for the provider. It implies that you can globally configure the pooling behavior for all the 
database instances with `pooling.PROVIDER_NAME.PROPERTY_NAME` and then override any values for specific instances with 
`pooling.DB_INSTANCE_NAME.PROPERTY_NAME`.
>[!WARNING]
> Note that setting instance specific pooling properties only does not enable pooling, you would need to set 
> `pooling.provider.name` or at least one property globally for the provider.

# Technical Support
For more details about Flona and technical support, please reach out to us via our [contact us](https://amiyul.com/contact-us) 
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
