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
