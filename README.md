# FlonaDB
FlonaDB is an abstraction of a database proxy that allows client application to loosely connect to target databases
using unique logical names.

This repository is used to host documentation, [issues](https://github.com/flonadb/flonadb/issues) and 
[discussions](https://github.com/flonadb/flonadb/discussions) for the [flonadb](http://flonadb.org) project and not the 
source code.

## End-User License Agreement
See [End-User License Agreement](https://amiyul.com/flonadb-eula)

## Copyright
See [Copyright](copyright.txt)

## Documentation
This documentation is for the 1.0.0 version, for documentation for other versions please see [here](https://github.com/flonadb/flonadb#readme).

## Table Of Contents
1. Overview
    - [What is FlonaDB?](#what-is-flonadb)
2. Getting Started
    - [Getting FlonaDB Driver](#getting-flonadb-driver)
    - [Quick Start](#quick-start)
3. Database Implementations
    - [Proxy Database Overview](#proxy-database-overview)
    - [File Database](#file-database)
4. Configuration
    - [File Database Configuration](#file-database-configuration)
5. API docs
    - [FlonaDataSource](#flonadatasource)

## What is FlonaDB?
FlonaDB is an abstraction of a database proxy that allows your application to loosely connect to target databases using
unique logical names or keys. It differs from a traditional database because it can't be used alone without a
traditional target database. In fact, you can have multiple applications connect to multiple databases using a single
centralized configuration.

It also differs from other database proxies because currently it requires no extra server setup since the proxy
mechanism is executed in the client application unless the proxy database implementation is orchestrated in such a way
that it communicates with a remote server. This implies that depending on the proxy database implementation, flonaDB can
act as a forward or reverse proxy or both.

The proxy database knows about the location of the target databases and any other necessary information needed to
connect to them e.g. connection URL, username, password etc.

There is a lot of possibilities that come to mind if you carefully think through all this, you can sandwich a plethora
of cool centralized features between your applications and the target databases.

**Note:** Currently, only a JDBC driver is available for flonaDB.

## Getting FlonaDB Driver

### Download
You can [download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-driver-single&v=1.0.0&e=jar) the single jar file using the download button below and add it to your classpath.

### Maven
Add the driver dependency below to your pom file.
``` xml
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-driver-final</artifactId>
    <version>1.0.0</version>
</dependency>
```

## Quick Start
### Requirements
- Flona driver requires Java 8 and the above.
- FlonaDB driver jar
- The drivers for the respective target databases.

### Proxy Database Configuration
As of version 1.0.0, [File Database](#file-database) is the only proxy DB implementation therefore it is the one we are 
going to use in all our examples.

The location of the database config file can be specified via an environment variable or a JVM system property named 
`FLONA_FILE_DB_CFG_LOCATION`, below is an example of the contents of the file-based database config file.

Proxy DB Config Example
``` properties
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

### Using Flona
Checklist:

Add the flona and target database drivers to your application's classpath.
Configure the location of the file based database config file

#### Using Flona Driver
Driver Connection URL Example
``` java
Connection c = DriverManager.getConnection("jdbc:flona://mysql-prod");
```
The URL above is used to connect to a target database named `mysql-prod` defined in the proxy database config file we 
created.

#### Using Flona DataSource
Flona driver also provides [FlonaDataSource](#flonadatasource) which is a JDBC `DataSource` implementation and below is an 
example demonstrating how to use it.

FlonaDataSource Example
``` java
FlonaDataSource ds = new FlonaDataSource();
ds.setTargetDatabaseName("targetDbName");
Connection c = ds.getConnection();
```

## Proxy Database Overview
FlonaDB database implementations are simple but powerful abstractions of a database proxy, depending on the 
implementation, the proxy mechanism can be run 100% within the client application or partially while the other part 
running a remote server. The proxy knows the locations and any other necessary information needed to connect to the 
databases.

You can use a single shared configuration file in order to manage the configurations in a single place. E.g. you could 
store the file on a shared drive that is accessed by all applications using flonaDB, this approach would typically apply 
to distributed systems with multiple nodes to centralize the management of the database credentials used by all the nodes.

As of version 1.0.0, [File Database](#file-database) is the only available implementation, it is a local implementation 
meaning both the driver and proxy DB are configured and run in the same JVM as the application, it implies you need to 
add both the flona driver and any necessary target DB driver(s) to your application's the classpath, more 
implementations will be added in future versions.

## File Database
File Database
A proxy database implementation that is configured in a file, it is 100% client side and runs inside the same JVM as the 
client application.

The location of the config file can be specified via an environment variable or a JVM system property named 
`FLONA_FILE_DB_CFG_LOCATION`, below is an example of the contents of the config file.

File Database Config Example
```
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

## File Database Configuration
**Note:** `{TARGET_DB_NAME}` is a placeholder where it exists in a property name and must be replaced with the target 
database name, implying the values for those properties only apply to a single target database.

|Name|Description|Required|Default Value|
|---|---|:---:|---|
|databases|A comma-separated list of the unique names of the target databases|Yes||
|`{TARGET_DB_NAME}`.url|The URL of the database to which to connect.|Yes||
|`{TARGET_DB_NAME}`.properties.user|The user to use to connect to the database.|No||
|`{TARGET_DB_NAME}`.properties.password|The user password to use to connect to the database.|No||


## API Docs
### FlonaDataSource
### Class FlonaDataSource
**Package:** com.amiyul.flona.driver

public class FlonaDataSource implements DataSource

---
### Constructors
`public FlonaDataSource()`

Default Constructor
<hr>

`public FlonaDataSource(String targetDatabaseName)`

Convenience constructor that takes the name of the target database to connect to.

**Parameters:**

`targetDatabaseName` - the name of the target database to connect to
<hr>

### Methods
> [!NOTE]
> Inherited methods are excluded.

**setTargetDatabaseName**

`public void setTargetDatabaseName(String targetDatabaseName)`

Sets the targetDatabaseName.

**Parameters:**

`targetDatabaseName` - the name of the target database to connect to
