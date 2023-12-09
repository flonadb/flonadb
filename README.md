# FlonaDB
FlonaDB is an abstraction of a database proxy that allows client application to loosely connect to target databases
using unique logical names.

This repository is used to host documentation, [issues](https://github.com/flonadb/flonadb/issues) and 
[discussions](https://github.com/flonadb/flonadb/discussions) for the [flonadb](http://flonadb.com) project and not the 
source code.

## Documentation
This documentation is for the latest released version, for documentation for older versions please see below,
- **1.0.0** - https://github.com/flonadb/flonadb/tree/1.0.0#readme

### Table Of Contents

1. Getting Started
   1. [Introduction](#introduction)
   2. [Getting FlonaDB Driver](#getting-flonadb-driver)
   3. [Quick Start](#quick-start)
2. Database Implementations
   1. [Proxy Database Overview](#proxy-database-overview)
   2. [File Database](#file-database)
3. Configuration
   1. [File Database Configuration](#file-database-configuration)
4. API docs
   1. [FlonaDataSource](#flonadatasource)
5. License
   1. [End-User License Agreement](#end-user-license-agreement)

### Introduction
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

Note: Currently, only a JDBC driver is available for flonaDB.

### Getting FlonaDB Driver
#### Download
You can [download](https://s01.oss.sonatype.org/service/local/artifact/maven/redirect?r=releases&g=com.amiyul.flona&a=flona-driver-single&v=1.0.0&e=jar) the single jar file using the download button below and add it to your classpath.


#### Maven
Add the dependency below to your pom file for the driver.
``` xml
<dependency>
    <groupId>com.amiyul.flona</groupId>
    <artifactId>flona-driver-final</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Quick Start


### Proxy Database Overview


### File Database


### File Database Configuration


### FlonaDataSource


### End-User License Agreement
