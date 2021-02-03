require 'redis'
Redis.current = Redis.new(host: "localhost")