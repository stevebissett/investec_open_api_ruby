require "investec_open_api/version"
require "investec_open_api/camel_case_refinement"
require "investec_open_api/client"

module InvestecOpenApi
  class Error < StandardError; end

  @api_key = nil
  @client_id = nil
  @client_secret = nil
  @scope = nil

  class << self
    attr_accessor :api_key, :client_id, :client_secret, :scope

    def configuration
      yield self
    end
  end
end
