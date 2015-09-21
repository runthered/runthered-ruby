require 'net/http'
require 'json'
require 'uri'

module RtrHttpGateway
  class HttpGatewayException < StandardError
  end

  # Represents The Delivery receipt status and reason code
  class DlrQueryResponse
    def initialize(status, reason_code, msg_id)
      @status = status
      @reason_code = reason_code
      @msg_id = msg_id
    end
    attr_reader :status, :reason_code, :msg_id
  end

  class HttpGatewayApi
    def initialize(username, password, service_key, url='https://connect.runthered.com:14004/public_api/sms/gateway/', dlr_url='https://connect.runthered.com:14004/public_api/sms/dlr/')
      @url = url
      @dlr_url = dlr_url
      @username = username
      @password= password
      @service_key = service_key
    end

    def do_post_request(url_string, values)
      uri = URI.parse(url_string)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(values)
      request.basic_auth @username, @password
      response = http.request(request)
      return response	
    end

    def do_get_request(url_string)
      uri = URI.parse(url_string)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth @username, @password
      response = http.request(request)
      return response
    end

    # Send a message to Run The Red
    # @param message [String] the message to send
    # @param to [String] the mobile number to send to
    # @param from_number [String] the shortcode the message will come from
    # @param billing_code [String] the billing code for the message, if required
    # @param partner_reference [String] a client supplied reference string, if required
    # @raise [HttpGatewayException] if a non 200 response is returned by Run The Red
    # @return [String] the message id of the message created in Run The Red's system
    def push_message(message, to, from_number=nil, billing_code=nil, partner_reference=nil)
      values = {'message'=>message, 'to'=>to}
      unless from_number.nil?
        values["from"] = from_number
      end
      unless billing_code.nil?
        values["billingCode"] = billing_code
      end
      unless partner_reference.nil?
        values["partnerReference"] = partner_reference
      end
      response = do_post_request(@url + @service_key, values)
      if response.code != '200'
        raise HttpGatewayException, response.code
      end
      return response.body
    end

    # Query a delivery receipt using the message id supplied by Run The Red
    # @param msg_id [String] the message id of the message to check the delivery status of
    # @raise [HttpGatewayException] if a non 200 response is returned by Ru The Red
    # @return [DlrQueryResponse] an object with the status, reason_code and msg_id as attributes		
    def query_dlr(msg_id)
      values = {'id' => msg_id}
      params = URI.encode_www_form(values)
      response = do_get_request(@dlr_url + @service_key + '?' + params)
      if response.code != '200'
        raise HttpGatewayException, response.code
      end
      data = JSON.parse response.body
      msg_id = data['id']
      status = data['status']
      reason_code = data['reason']
      return DlrQueryResponse.new(status, reason_code, msg_id)
    end
  end
end

