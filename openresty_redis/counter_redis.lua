        location /redistest {
                default_type 'text/plain';
                content_by_lua_block {
                        local redis = require "resty.redis"
                        local red = redis:new()
                        local ok, err = red:connect("127.0.0.1", 6379)
                        if not ok then
                                ngx.say("Failed to connect to the redis server, the error was: ", err)
                                return
                        end
                        local counter = red:get("counter")
                        if tonumber(counter) == nil then
                                counter = 0
                        end
                        counter = counter + 1
                        ngx.say(counter)
                        local ok, err = red:set("counter", counter)
                }
        }
