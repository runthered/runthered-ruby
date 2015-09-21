require 'net/http'
require 'json'
require 'uri'

module RtrPushApi

  # Represents The Push Api status and message id
  class PushApiResponse
    def initialize(status, msg_id, push_id)
      @status = status
      @msg_id = msg_id
      @id = push_id
    end
    attr_reader :status, :msg_id, :id
  end

  # Represents The Delivery receipt status and reason code
  class DlrQueryResponse
    def initialize(status, reason_code, push_id)
      @status = status
      @reason_code = reason_code
      @id = push_id
    end
    attr_reader :status, :reason_code, :id
  end

  class PushApiException < StandardError
  end

  class PushApi
    def initialize(username, password, service_key, url='https://connect.runthered.com:10443/public_api/service')
      @url = url
      @username = username
      @password = password
      @service_key = service_key
    end

    def do_json_request(data)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = data.to_json
      request.basic_auth @username, @password
      response = http.request(request)
      if response.code != '200'
        raise PushApiException, response.body
      else
        data = JSON.parse response.body
        if !data.has_key?("result")  
          error = data['error']
          message = error['message']
          code = error['code']
          raise PushApiException, message
        end
        return data
      end
      
      return response	
    end

    # Send a message to Run The Red
    # @param message [String] the message to send
    # @param to [String] the mobile number to send to
    # @param from_number [String] the shortcode the message will come from
    # @param push_id [Integer] the push_id sent by the client to comply with the JSON-RPC 2.0 spec
    # @return [PushApiResponse] a response object with the status, msg_id and id as attributes
    def push_message(message, to, from_number=nil, push_id=1)
      json_data = {"jsonrpc" => "2.0", "method" => "sendsms", "params" => {"service_key" => @service_key, "to" => to, "body" => message}, "id" => push_id}
      unless from_number.nil?
        json_data["params"]["frm"] = from_number
      end
      data = do_json_request(json_data)
      push_id = data['id']
      result = data['result']
      status = result['status']
      msg_id = result['msg_id']
      return PushApiResponse.new(status, msg_id, push_id)
    end

    # Query a delivery receipt using the message id supplied by Run The Red
    # @param msg_id [String] the message id of the message to check the delivery status of
    # @param push_id [Integer] the push_id sent by the client to comply with the JSON-RPC 2.0 spec
    # @return [DlrQueryResponse] an object with the status, reason_code and id as attributes		
    def query_dlr(msg_id, push_id=1)
      json_data = {"jsonrpc" => "2.0", "method" => "querydlr", "params" => {"service_key" => @service_key, "msg_id" => msg_id}, "id" => push_id}
      data = do_json_request(json_data)
      push_id = data['id']
      result = data['result']
      status = result['status']
      reason_code = result['reason']
      msg_id = result['msg_id']
      return DlrQueryResponse.new(status, reason_code, push_id)
    end
  end
end

