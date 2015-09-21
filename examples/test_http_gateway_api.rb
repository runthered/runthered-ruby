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
