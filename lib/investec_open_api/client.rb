require "faraday"
require "investec_open_api/models/account"
require "investec_open_api/models/transaction"
require "investec_open_api/models/document"
require "investec_open_api/camel_case_refinement"
require "pry"

class InvestecOpenApi::Client
  using InvestecOpenApi::CamelCaseRefinement
  INVESTEC_API_URL = "https://openapi.investec.com/"

  def authenticate!
    @token = get_oauth_token["access_token"]
  end

  def accounts
    response = connection.get("za/pb/v1/accounts")
    response.body["data"]["accounts"].map do |account_raw|
      InvestecOpenApi::Models::Account.from_api(account_raw)
    end
  end

  def documents(account_id, retrieve_document_file_content: true, from:, to:)
    url = "za/pb/v1/accounts/#{account_id}/documents"

    options = {
      fromDate: (from.is_a?(Date) ? from.to_s : from),
      toDate: (to.is_a?(Date) ? to.to_s : to)
    }.compact

    unless options.empty?
      query_string = URI.encode_www_form(options.camelize)
      url += "?#{query_string}"
    end

    response = connection.get(url)
    documents = response.body["data"]

    documents.map do |document_raw|
      document_content = retrieve_document_file_content ? document_content(account_id, document_raw["documentType"], document_raw["documentDate"]) : nil
      puts "Retrieved document content for #{document_raw["documentType"]} / #{document_raw["documentDate"]}"
      InvestecOpenApi::Models::Document.from_api(document_raw.merge(file_content: document_content))
    end
  end

  def document_content(account_id, document_type, document_date)
    url = "za/pb/v1/accounts/#{account_id}/document/#{document_type}/#{document_date}"

    response = connection.get(url)
    response_body = response.body

    response_body
  end

  def transactions(account_id, from: nil, to: nil, type: nil, page: nil)
    options = {
      fromDate: (from.is_a?(Date) ? from.to_s : from),
      toDate: (to.is_a?(Date) ? to.to_s : to),
      page: page,
      transactionType: type,
    }.compact

    endpoint_url = "za/pb/v1/accounts/#{account_id}/transactions"

    unless options.empty?
      query_string = URI.encode_www_form(options)
      endpoint_url += "?#{query_string}"
    end

    response = connection.get(endpoint_url)
    response.body["data"]["transactions"].map do |transaction_raw|
      InvestecOpenApi::Models::Transaction.from_api(transaction_raw)
    end
  end

  private

  def get_oauth_token
    auth_token = Base64.strict_encode64("#{InvestecOpenApi.client_id}:#{InvestecOpenApi.client_secret}")

    response = Faraday.post(
      "#{INVESTEC_API_URL}identity/v2/oauth2/token",
      { grant_type: "client_credentials" },
      {
        "x-api-key" => InvestecOpenApi.api_key,
        "Authorization" => "Basic #{auth_token}",
      }
    )

    JSON.parse(response.body)
  end

  def connection
    @_connection ||= Faraday.new(url: INVESTEC_API_URL) do |builder|
      if @token
        builder.headers["Authorization"] = "Bearer #{@token}"
      end

      builder.headers["Accept"] = "application/json"
      builder.request :json

      builder.response :raise_error
      builder.response :json

      builder.adapter Faraday.default_adapter
    end
  end
end
