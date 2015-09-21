# runthered-ruby

A Ruby Run The Red API helper library.

# Installation

gem install runthered_ruby

# Examples

## HTTP Gateway

### Send an MT and query a delivery reciept using a message id
```ruby
require "runthered_ruby"
username = "snoop7"
password = "snoop7"
service_key = "snop7"
http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
message = "testit"
to = "64212540313"
from = "2059"
begin
  resp = http_gateway_api.push_message(message, to, from)
  puts "Sent message with msg_id #{resp}"
  msg_id = "55f255afe13823069edbdf8b"
  dlr_resp = http_gateway_api.query_dlr(msg_id)
  puts "The dlr status is " + dlr_resp.status
  puts "The dlr reason is " + dlr_resp.reason_code
rescue RtrHttpGateway::HttpGatewayException => e
  puts "RtrHttpGateway failed with error #{e}"
end
```

## Push API

### Send an MT and query a delivery reciept using a message id
```ruby
require "runthered_ruby"

username = "testuser"
password = "testuser"
service_key = "82221"
push_api = RtrPushApi::PushApi.new(username, password, service_key)

message = "Hello World!"
to = "64212540313"
from = "8222"
begin
  resp = push_api.push_message(message, to, from)
  puts "Sent message with msg_id #{resp.msg_id}"
  puts "The status is #{resp.status}"
  puts "The id is #{resp.id}"
  msg_id = "55f7a70ee13823069edbdfb2"
  dlr_id = 12346
  dlr_resp = push_api.query_dlr(msg_id, dlr_id)
  puts "The dlr status is " + dlr_resp.status
  puts "The dlr reason is " + dlr_resp.reason_code
  puts "The dlr id is #{dlr_resp.id}"
rescue RtrPushApi::PushApiException => e
  puts "RtrPushApi failed with error #{e}"
end
```
