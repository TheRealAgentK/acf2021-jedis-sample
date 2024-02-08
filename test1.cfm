<cfscript>
// No need to CFAdmin config anything
// Dependency: cfpm install caching to get the Jedis libraries loaded

// Default cache engine is EHCache, we're not changing that.
WriteDump(CacheGetEngineProperties()); // Returns the properties of the cache engine
WriteOutput("The caching engine currently used is: " & CacheGetEngineProperties().name); // Returns the name of the cache engine

cowSays = cacheGet( "cow" );
if ( isNull( cowSays ) ) {
    cowSays = "moo";
    cachePut( "cow", cowSays, createTimeSpan( 0, 0, 30, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
}
writeOutput( "<br>" );
writeOutput( "The cow says " & cowSays );


// Create JedisPoolConfig (more complicated than necessary for our example, but will need to be done this way for a real app)
jedisPoolConfig = createObject( "java", "redis.clients.jedis.JedisPoolConfig" ).init();
jedisPoolConfig.setMaxTotal( 128 );
jedisPoolConfig.setMaxIdle( 128 );
jedisPoolConfig.setMinIdle( 16 );

// Creating JedisPool (it's thread-safe)
application.jedisPool = createObject( "java", "redis.clients.jedis.JedisPool" ).init(
    JedisPoolConfig,
    "127.0.0.1", 
    6379
);

writeDump(application.jedisPool);

// Get JedisClient from JedisPool for usage
jedisClient = application.jedisPool.getResource();
writedump(jedisClient)

// Set and get a field
jedisClient.set("testkai-acf","1234");
// As soon as there are two keys in a namespace, it shows up like a namespace in tools like Redis Desktop Manager
jedisClient.set("myapp:testkai-acf","5678");
jedisClient.set("myapp:testkai-acf2","666");

writeOutput(jedisClient.get("testkai-acf"));
writeOutput(jedisClient.get("myapp:testkai-acf"));
writeOutput(jedisClient.set("myapp:testkai-acf2","666"));

// Return into pool
application.jedisPool.returnResource(jedisClient);

</cfscript>