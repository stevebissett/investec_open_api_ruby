require "spec_helper"
require "investec_open_api/client"
require "investec_open_api/models/account"
require "investec_open_api/models/transaction"
require "investec_open_api/models/card"
require "investec_open_api/models/code/execution"
require "investec_open_api/models/code/execution_log"
#require "investec_open_api/models/reference/country"

RSpec.describe InvestecOpenApi::Client do
  let(:client) { InvestecOpenApi::Client.new }
  let(:api_url) { "https://openapi.investec.com/" }

  before do
    InvestecOpenApi.api_key = "TESTKEY"
    InvestecOpenApi.client_id = "Test"
    InvestecOpenApi.client_secret = "Secret"

    stub_request(:post, "#{api_url}identity/v2/oauth2/token")
      .with(
        body: { "grant_type" => "client_credentials" },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic VGVzdDpTZWNyZXQ=",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Faraday v2.9.0",
          "X-Api-Key" => "TESTKEY",
        },
      )
      .to_return(status: 200, body: {
                   "access_token": "123",
                   "token_type": "Bearer",
                   "expires_in": 1799,
                   "scope": "accounts",
                 }.to_json, headers: {})
  end

  describe "#accounts" do
    before do
      stub_request(:get, "#{api_url}za/pb/v1/accounts")
        .with(
          body: "",
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "Bearer 123",
            "User-Agent" => "Faraday v2.9.0",
          },
        )
        .to_return(
          body: {
            data: {
              accounts: [
                {
                  "accountId" => "12345",
                  "accountNumber" => "67890",
                  "accountName" => "Test User",
                  "referenceName" => "My Private Investec Bank Account",
                  "productName" => "Private Bank Account",
                  "profileId" => "12345",
                  "profileName" => "Test User",
                },
                {
                  "accountId" => "223344",
                  "accountNumber" => "556677",
                  "accountName" => "Test User",
                  "referenceName" => "My Private Investec Savings Account",
                  "productName" => "Private Savings Account",
                  "profileId" => "12345",
                  "profileName" => "Test User",
                },
              ],
            },
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
          },
        )

      client.authenticate!
    end

    it "returns all accounts for the authorized user as InvestecOpenApi::Models::Account instances" do
      accounts = client.accounts

      expect(accounts.first).to be_an_instance_of(InvestecOpenApi::Models::Account)

      expect(accounts.first.id).to eq "12345"
      expect(accounts.first.number).to eq 67890
      expect(accounts.first.name).to eq "Test User"
      expect(accounts.first.reference_name).to eq "My Private Investec Bank Account"
      expect(accounts.first.product_name).to eq "Private Bank Account"

      expect(accounts.last.id).to eq "223344"
      expect(accounts.last.number).to eq 556677
      expect(accounts.last.name).to eq "Test User"
      expect(accounts.last.reference_name).to eq "My Private Investec Savings Account"
      expect(accounts.last.product_name).to eq "Private Savings Account"
    end
  end

  describe "#transactions" do
    let(:transaction_data) do
      {
        data: {
          transactions: [
            {
              "accountId": "12345",
              "type": "DEBIT",
              "status": "POSTED",
              "description": "MONTHLY SERVICE CHARGE",
              "cardNumber": "",
              "postedOrder": 1,
              "postingDate": "2020-06-11",
              "valueDate": "2020-06-10",
              "actionDate": "2020-06-18",
              "amount": 535,
              "transactionDate": "2020-06-10",
              "runningBalance": 100000.64,
              "transactionType": "CardPurchases",
            },
            {
              "accountId": "12345",
              "type": "CREDIT",
              "status": "POSTED",
              "description": "CREDIT INTEREST",
              "cardNumber": "",
              "postedOrder": 2,
              "postingDate": "2020-06-11",
              "valueDate": "2020-06-10",
              "actionDate": "2020-06-18",
              "amount": 31.09,
              "transactionDate": "2020-06-10",
              "runningBalance": 100000.64,
              "transactionType": "CardPurchases",
            },
          ],
        },
      }.to_json
    end

    let(:headers) do
      {
        "Accept" => "application/json",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Authorization" => "Bearer 123",
        "User-Agent" => "Faraday v2.9.0",
      }
    end

    before do
      client.authenticate!
    end

    context "when no filter parameters are specified" do
      before do
        stub_request(:get, "#{api_url}za/pb/v1/accounts/12345/transactions")
          .with(body: "", headers: headers)
          .to_return(
            body: transaction_data,
            headers: {
              "Content-Type" => "application/json",
            },
          )
      end

      it "returns all transactions for the specified account id as InvestecOpenApi::Models::Transaction instances" do
        transactions = client.transactions("12345")
        expect(transactions.first).to be_an_instance_of(InvestecOpenApi::Models::Transaction)
      end
    end

    context "when filter parameters are specified" do
      let(:options) { { from: "2021-01-01", to: "2023-01-01", page: 4 } }

      before do
        stub_request(:get, "#{api_url}za/pb/v1/accounts/12345/transactions?fromDate=2021-01-01&toDate=2023-01-01&page=4")
          .with(body: "", headers: headers)
          .to_return(
            body: transaction_data,
            headers: {
              "Content-Type" => "application/json",
            },
          )
      end

      it "returns all transactions for the specified account id as InvestecOpenApi::Models::Transaction instances" do
        transactions = client.transactions("12345", **options)
        expect(transactions.first).to be_an_instance_of(InvestecOpenApi::Models::Transaction)
      end
    end
  end

  describe "#cards" do
    before do
      stub_request(:get, "#{api_url}za/v1/cards")
        .with(
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "Bearer 123",
            "User-Agent" => "Faraday v2.9.0",
          },
        )
        .to_return(
          body: {
            data: {
              cards: [
                {
                  "CardKey": "1234",
                  "CardNumber": "401234XXXXXX2020",
                  "IsProgrammable": true,
                  "Status": "Active",
                  "CardTypeCode": "VGC",
                  "AccountNumber": "12394234",
                  "AccountId": "238008073828482846",
                  "EmbossedName": "MR J KRUGER",
                  "IsVirtualCard": false,
                },
                {
                  "CardKey": "1235",
                  "CardNumber": "401234XXXXXX2030",
                  "IsProgrammable": true,
                  "Status": "Active",
                  "CardTypeCode": "VVG",
                  "AccountNumber": "12394234",
                  "AccountId": "238008073828482846",
                  "EmbossedName": "ONLINE SHOPPING CARD",
                  "IsVirtualCard": true,
                },
              ],
            },
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
          },
        )

      client.authenticate!
    end

    it "returns all accounts for the authorized user as InvestecOpenApi::Models::Card instances" do
      cards = client.cards

      expect(cards.first).to be_an_instance_of(InvestecOpenApi::Models::Card)
      expect(cards.first.key).to eq "1234"
      expect(cards.first.number).to eq "401234XXXXXX2020"
      expect(cards.first.is_programmable).to eq true
      expect(cards.first.status).to eq "Active"
      expect(cards.first.type_code).to eq "VGC"
      expect(cards.first.account_number).to eq "12394234"
      expect(cards.first.account_id).to eq "238008073828482846"
      expect(cards.first.embossed_name).to eq "MR J KRUGER"
      expect(cards.first.is_virtual).to eq false
    end
  end

  describe "#code_executions" do
    before do
      stub_request(:get, "#{api_url}za/v1/cards/1234/code/executions")
        .with(
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "Bearer 123",
            "User-Agent" => "Faraday v2.9.0",
          },
        )
        .to_return(
          body: {
            data: {
              result: {
                executionItems: [
                  {
                    "executionId": "AABBCCDD-1234-1234-1234-12345ABCDEF",
                    "rootCodeFunctionId": "AABBCCDD-1234-1234-1234-54321ABCDEF",
                    "sandbox": false,
                    "type": "before_transaction",
                    "authorizationApproved": nil,
                    "logs": [
                      {
                        "createdAt": "2024-04-14T13:18:38.501Z",
                        "level": "info",
                        "content": "log content",
                      },
                    ],
                    "smsCount": 0,
                    "emailCount": 0,
                    "pushNotificationCount": 0,
                    "createdAt": "2024-04-14T13:18:38.201Z",
                    "startedAt": "2024-04-14T13:18:38.201Z",
                    "completedAt": "2024-04-14T13:18:38.801Z",
                    "updatedAt": "2024-04-14T13:18:38.201Z",
                  },
                ],
              },
            },
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
          },
        )

      client.authenticate!
    end

    it "returns all code executions for the specified card key as InvestecOpenApi::Models::Code::Execution instances" do
      code_executions = client.code_executions("1234")

      expect(code_executions.first).to be_an_instance_of(InvestecOpenApi::Models::Code::Execution)
      expect(code_executions.first.logs.first).to be_an_instance_of(InvestecOpenApi::Models::Code::ExecutionLog)
      expect(code_executions.first.id).to eq "AABBCCDD-1234-1234-1234-12345ABCDEF"
      expect(code_executions.first.root_code_function_id).to eq "AABBCCDD-1234-1234-1234-54321ABCDEF"
    end
  end
end
