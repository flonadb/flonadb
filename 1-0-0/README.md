# FlonaDB v1.0.0 Documentation

## Table Of Contents
1. [Overview](#overview)
2. [Features Overview](#features-overview)
3. [Getting Started](#getting-started)
    1. [Getting FlonaDB Driver](#getting-flonadb-driver)
    2. [Quick Start](#quick-start)
4. [Proxy DB Implementations](#proxy-db-implementations)
    1. [Proxy Database Overview](#proxy-database-overview)
    2. [File Database Proxy](#file-database-proxy)
5. [Advanced Configuration](#advanced-configuration)
    1. [File Database Configuration](#file-database-configuration)
6. [Technical Support](#technical-support)
7. [Request A New Feature Or File A Bug](#request-a-new-feature-or-file-a-bug)
8. [Discussions And Announcements](#discussions-and-announcements)
9. [End-User License Agreement](#end-user-license-agreement)

## Overview
FlonaDB is an abstraction of a database proxy that allows your application to loosely connect to target databases using 
unique logical names or keys. It differs from a traditional database because it can't be used alone without a 
traditional target database. In fact, you can have multiple applications connect to multiple databases using a single 
centralized configuration and setup.

It also differs from other database proxies because currently it requires no extra server setup since the proxy 
mechanism is executed in the client application unless the proxy database implementation is orchestrated in such a way 
that it communicates with a remote server. This implies that depending on the proxy database implementation, FlonaDB can 
act as a forward or reverse proxy or both.

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

## Features Overview
Note that all the features below are independent of the target database management system.
- Client applications identify target databases using intuitive unique logical names instead of host name and port.
- Centralized management of target database connection credentials like host name, port, username, password and other 
  required information for multiple applications making it easier to update all applications at once when the connection 
  credentials change, it can be very frustrating to wake up in the morning and a weekly batch processing job which runs 
  at night failed since the application could not connect to the database because the database admin performed a routine 
  update of the passwords during the day.
- Database system independence, it means in theory you can swap the target database system without changing client code
  as long as the client applications are written in such a way that they are agnostic to the target database system
  behind. And, you can plug in features that cut across all the database systems like collecting statistics, a custom
  security model, connection timeouts, data masking etc.

We're constantly adding new important features to FlonaDB in newer versions.

## Getting Started
### Getting FlonaDB Driver
#### Download

You can [download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-driver-single&v=1.0.0&e=jar) 
the single jar file and add it to your classpath.

#### Maven

Add the dependency below to your pom file for the driver.
```xml
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-driver-final</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Quick Start
#### Requirements 
- Flona driver requires Java 8 and above.
- FlonaDB driver jar
- The JDBC drivers for the respective target database systems.

#### Proxy Database Configuration

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

#### Connecting To The Database
Make sure you have done the following below,

- Added to your application's classpath the Flona DB and the drivers for your target database system.
- Configured the location of the [file based database](#file-database-configuration) config file

Obtaining a connection:

```java
Connection c = DriverManager.getConnection("jdbc:flona://mysql-prod"); 
```

The URL above is used to connect to a target database named `mysql-prod` defined in the proxy database config file we 
created.

Obtaining a connection using Flona data source:

Flona driver also provides `com.amiyul.flona.driver FlonaDataSource` which is a JDBC `DataSource` implementation and 
below is an example demonstrating how to use it to obtain a connection to a target database named `mysql-prod`.

```java
FlonaDataSource ds = new FlonaDataSource();
ds.setTargetDatabaseName("mysql-prod");
Connection c = ds.getConnection();

```

## Proxy DB Implementations
### Proxy Database Overview
FlonaDB database implementations are simple but powerful abstractions of a database proxy. The proxy knows the locations 
and any other necessary information needed to connect to the databases.

You can use a single shared configuration file in order to manage the configurations in a single place. E.g. you could
store the file on a shared drive that is accessed by all applications using Flona, this approach would typically apply
to distributed systems with multiple nodes to centralize the management of the database credentials used by all the
nodes.

As of version 1.1.0, [File Database Proxy](#file-database-proxy) is the only available implementation, it is a local implementation
meaning both the driver and proxy DB are configured and run in the same JVM as the application, it implies you need to
add both the Flona driver and any necessary target DB driver(s) to your application's the classpath, more
implementations will be added in future versions.

### File Database Proxy
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

## Advanced Configuration
### File Database Configuration
**Note:** `TARGET_DB_NAME` is a placeholder where it exists in a property name and must be replaced with the target 
database name, implying the values for those properties only apply to a single target database.

| Name | Description | Required | Default Value |
|------|-------------|:--------:|:-------------:|
|databases| A comma-separated list of the unique names of the target databases.|Yes||
|TARGET_DB_NAME.url|The URL of the database to which to connect.|Yes||
|TARGET_DB_NAME.properties.user|The user to use to connect to the database.|No||
|TARGET_DB_NAME.properties.password|The user password to use to connect to the database.|No||

## Technical Support
For more details about FlonaDB and technical support, please reach out to us via our [contact us](https://amiyul.com/contact-us) 
page.

## Request A New Feature Or File A Bug
Please see [here](https://github.com/flonadb/flonadb/issues)

## Discussions And Announcements
Please see [here](https://github.com/flonadb/flonadb/discussions)

## End-User License Agreement
See [End-User License Agreement](https://amiyul.com/flonadb-eula)
