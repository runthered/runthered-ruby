require 'minitest/autorun'
require 'webmock/minitest'
require 'runthered_ruby'

class RtrHttpGatewayTest < Minitest::Test
  def test_rtr_http_gateway_success
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:14004/public_api/sms/gateway/#{service_key}").
  with(:body => {"from"=>"#{from_number}", "message"=>"#{message}", "to"=>"#{to}"},
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "#{msg_id}", :headers => {})

    response = http_gateway_api.push_message(message, to, from_number)

    assert_equal "#{msg_id}",
      response
  end
 
  def test_rtr_http_gateway_dlr_success
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
    
    msg_id = "55f255afe13823069edbdf8b"

   stub_request(:get, "https://#{username}:#{password}@connect.runthered.com:14004/public_api/sms/dlr/#{service_key}?id=#{msg_id}").
  with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 200, :body => "{\"id\": \"#{msg_id}\", \"status\": \"DELIVRD\", \"reason\": \"000\"}", :headers => {})

    response = http_gateway_api.query_dlr(msg_id)

    assert_equal "DELIVRD",
      response.status
    assert_equal "000",
      response.reason_code
    assert_equal "#{msg_id}",
      response.msg_id
  end

  def test_rtr_http_gateway_unauthorised
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
    
    to = '64212431234'
    from_number = '8222'
    message = 'bob the builder'
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:14004/public_api/sms/gateway/#{service_key}").
  with(:body => {"from"=>"#{from_number}", "message"=>"#{message}", "to"=>"#{to}"},
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
  to_return(:status => 401, :body => "Unauthorized", :headers => {})

    assert_raises(RtrHttpGateway::HttpGatewayException) {http_gateway_api.push_message(message, to, from_number)}
  end

  def test_rtr_http_gateway_dlr_unauthorised
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
    
    msg_id = "55f255afe13823069edbdf8b"

   stub_request(:get, "https://#{username}:#{password}@connect.runthered.com:14004/public_api/sms/dlr/#{service_key}?id=#{msg_id}").
  with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 401, :body => "Unauthorized", :headers => {})

    assert_raises(RtrHttpGateway::HttpGatewayException) {http_gateway_api.query_dlr(msg_id)}
  end
  
  def test_rtr_http_gateway_error
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
    
    to = ''
    from_number = '8222'
    message = 'bob the builder'
    msg_id = "55f255afe13823069edbdf8b"

    stub_request(:post, "https://#{username}:#{password}@connect.runthered.com:14004/public_api/sms/gateway/#{service_key}").
  with(:body => {"from"=>"#{from_number}", "message"=>"#{message}", "to"=>"#{to}"},
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
  to_return(:status => 400, :body => "Invalid mobile number: no to number", :headers => {})

    assert_raises(RtrHttpGateway::HttpGatewayException) {http_gateway_api.push_message(message, to, from_number)}
  end

  def test_rtr_http_gateway_dlr_unauthorised
    username = 'fred'
    password = 'fred'
    service_key = 'bob12'
    http_gateway_api = RtrHttpGateway::HttpGatewayApi.new(username, password, service_key)
    
    msg_id = "55f255afe13823069edbdf8a"

   stub_request(:get, "https://#{username}:#{password}@connect.runthered.com:14004/public_api/sms/dlr/#{service_key}?id=#{msg_id}").
  with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
  to_return(:status => 404, :body => "{\"message\": \"Unknown Message Id: Could not find message id #{msg_id}\", \"code\": 404}", :headers => {})

    assert_raises(RtrHttpGateway::HttpGatewayException) {http_gateway_api.query_dlr(msg_id)}
  end

end
