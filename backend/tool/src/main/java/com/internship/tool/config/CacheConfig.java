package com.internship.tool.config;

import org.springframework.cache.CacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;

import java.time.Duration;

/**
 * Redis Cache Configuration
 * Sets up caching with 10-minute TTL for all cache entries
 */
@Configuration
public class CacheConfig {

    /**
     * Configures the cache manager with Redis backend
     * All cache entries will expire after 10 minutes
     */
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory redisConnectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .disableCachingNullValues();

        return RedisCacheManager.create(redisConnectionFactory);
    }
}

