require 'minitest/autorun'
require 'webmock/minitest'
require 'runthered_ruby'

class RtrPushApiTest < Minitest::Test
  def test_rtr_push_api_success
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    push_api = RtrPushApi::PushApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    push_id = 4
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:10443/public_api/service").
  with(:body => "{\"jsonrpc\":\"2.0\",\"method\":\"sendsms\",\"params\":{\"service_key\":\"#{service_key}\",\"to\":\"#{to}\",\"body\":\"#{message}\",\"frm\":\"#{from_number}\"},\"id\":#{push_id}}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "{\"jsonrpc\": \"2.0\", \"id\": #{push_id}, \"result\": {\"status\": \"Accepted\", \"msg_id\": \"#{msg_id}\"}}", :headers => {})
     
    response = push_api.push_message(message, to, from_number, push_id)

    assert_equal "#{msg_id}",
      response.msg_id
    assert_equal "Accepted",
      response.status
    assert_equal push_id,
      response.id
  end

  def test_rtr_push_api_dlr_success
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    push_api = RtrPushApi::PushApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    push_id = 4
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:10443/public_api/service").
  with(:body => "{\"jsonrpc\":\"2.0\",\"method\":\"querydlr\",\"params\":{\"service_key\":\"#{service_key}\",\"msg_id\":\"#{msg_id}\"},\"id\":#{push_id}}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "{\"jsonrpc\": \"2.0\", \"id\": #{push_id}, \"result\": {\"status\": \"DELIVRD\", \"reason\": \"000\", \"msg_id\": \"#{msg_id}\"}}", :headers => {})
       
    response = push_api.query_dlr(msg_id, push_id)

    assert_equal "DELIVRD",
      response.status
    assert_equal "000",
      response.reason_code
    assert_equal push_id,
      response.id
  end
 
  def test_rtr_push_api_unauthorised
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    push_api = RtrPushApi::PushApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    push_id = 4
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:10443/public_api/service").
  with(:body => "{\"jsonrpc\":\"2.0\",\"method\":\"sendsms\",\"params\":{\"service_key\":\"#{service_key}\",\"to\":\"#{to}\",\"body\":\"#{message}\",\"frm\":\"#{from_number}\"},\"id\":#{push_id}}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 401, :body => "Unauthorized", :headers => {})
     
    assert_raises(RtrPushApi::PushApiException) {push_api.push_message(message, to, from_number, push_id)}
  end

  def test_rtr_push_api_dlr_unauthorised
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    push_api = RtrPushApi::PushApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    push_id = 4
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:10443/public_api/service").
  with(:body => "{\"jsonrpc\":\"2.0\",\"method\":\"querydlr\",\"params\":{\"service_key\":\"#{service_key}\",\"msg_id\":\"#{msg_id}\"},\"id\":#{push_id}}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 401, :body => "Unauthorized", :headers => {})
       
    assert_raises(RtrPushApi::PushApiException) {push_api.query_dlr(msg_id, push_id)}
  end

  def test_rtr_push_api_error
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    push_api = RtrPushApi::PushApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    push_id = 4
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:10443/public_api/service").
  with(:body => "{\"jsonrpc\":\"2.0\",\"method\":\"sendsms\",\"params\":{\"service_key\":\"#{service_key}\",\"to\":\"#{to}\",\"body\":\"#{message}\",\"frm\":\"#{from_number}\"},\"id\":#{push_id}}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "{\"jsonrpc\": \"2.0\", \"id\": #{push_id}, \"error\": {\"message\": \"Invalid shortcode.\", \"code\": -1}}", :headers => {})
     
    assert_raises(RtrPushApi::PushApiException) {push_api.push_message(message, to, from_number, push_id)}
  end

  def test_rtr_push_api_dlr_error
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    push_api = RtrPushApi::PushApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    push_id = 4
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:10443/public_api/service").
  with(:body => "{\"jsonrpc\":\"2.0\",\"method\":\"querydlr\",\"params\":{\"service_key\":\"#{service_key}\",\"msg_id\":\"#{msg_id}\"},\"id\":#{push_id}}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "{\"jsonrpc\": \"2.0\", \"id\": #{push_id}, \"error\": {\"message\": \"Unknown Message Id.\", \"code\": -11}}", :headers => {})
       
    assert_raises(RtrPushApi::PushApiException) {push_api.query_dlr(msg_id, push_id)}
  end

end
