require 'fileutils'
require 'json'

module InvestecOpenApi
  class LoggingMiddleware < Faraday::Middleware
    def initialize(app, log_dir = nil)
      super(app)
      @log_dir = log_dir || File.join(File.dirname(__FILE__), '..', 'api_request_logs')
      FileUtils.mkdir_p(@log_dir) unless Dir.exist?(@log_dir)
    end

    def call(env)
      @app.call(env).on_complete do |response_env|
        log_to_file(env, response_env)
      end
    end

    private

    def log_to_file(request_env, response_env)
      log_data = {
        request: {
          method: request_env.method,
          url: request_env.url.to_s,
          headers: sanitize_headers(request_env.request_headers),
          body: request_env.request_body
        },
        response: {
          status: response_env.status,
          headers: sanitize_headers(response_env.response_headers),
          body: response_env.response_body
        }
      }

      timestamp = Time.now.utc
      file_name = timestamp.strftime('%Y-%m-%d_%H-%M-%S_%L_UTC.json')
      File.open(File.join(@log_dir, file_name), 'w') do |file|
        file.write(JSON.pretty_generate(log_data))
      end
    end

    def sanitize_headers(headers)
      headers.map do |key, value|
        if sensitive_header?(key)
          [key, "[FILTERED]"]
        else
          [key, value]
        end
      end.to_h
    end

    def sensitive_header?(header_name)
      ['Authorization', 'x-api-key'].include?(header_name)
    end
  end
end
