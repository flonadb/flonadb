# FlonaDB
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
