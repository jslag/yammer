require 'faraday'

# @private
module Faraday
  # @private
  class Response::RaiseHttp4xx < Response::Middleware
    def on_complete(env)
      case env[:status].to_i
      when 400
        raise Yammer::BadRequest.new(error_message(env), env[:response_headers])
      when 401
        raise Yammer::Unauthorized.new(error_message(env), env[:response_headers])
      when 403
        raise Yammer::Forbidden.new(error_message(env), env[:response_headers])
      when 404
        raise Yammer::NotFound.new(error_message(env), env[:response_headers])
      when 406
        raise Yammer::NotAcceptable.new(error_message(env), env[:response_headers])
      end
    end

    private

    def error_message(env)
      "#{env[:method].to_s.upcase} #{env[:url].to_s}: #{env[:status]}#{error_body(env[:body])}"
    end

    def error_body(body)
      if body.nil?
        nil
      elsif body.is_a?(String)
        body
      elsif body['error']
        ": #{body['error']}"
      elsif body['errors']
        first = Array(body['errors']).first
        if first.kind_of? Hash
          ": #{first['message'].chomp}"
        else
          ": #{first.chomp}"
        end
      end
    end
  end
end
