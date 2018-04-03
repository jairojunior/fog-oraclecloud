module Fog
  module OracleCloud
    class SOA < Fog::Service
      requires :oracle_username, :oracle_password, :oracle_domain
      recognizes :oracle_region

      model_path	'fog/oraclecloud/models/soa'
      model	:instance
      collection	:instances

      request_path 'fog/oraclecloud/requests/soa'
      request :list_instances
      request :create_instance
      request :get_instance
      request :delete_instance
      request :get_job_status

      class Real
        def initialize(options = {})
          @username = options[:oracle_username]
          @password = options[:oracle_password]
          @identity_domain = options[:oracle_domain]
          region_url = options[:oracle_region] == 'emea' ? 'https://jcs.emea.oraclecloud.com' : 'https://jaas.oraclecloud.com'
          Excon.ssl_verify_peer = false

          @connection = Fog::XML::Connection.new(region_url)
        end

        attr_reader :username

        attr_reader :password

        def auth_header
          auth_header ||= 'Basic ' + Base64.encode64("#{@username}:#{@password}").delete("\n")
        end

        def request(params, parse_json = true, &block)
          begin
            Fog::Logger.debug("Sending #{params[:body]} to #{params[:path]}")
            response = @connection.request(params.merge!(
                                             headers: {
                                               'Authorization' => auth_header,
                                               'X-ID-TENANT-NAME' => @identity_domain,
                                               'Content-Type' => 'application/json',
                                               'Accept'       => 'application/json'
                                             }.merge!(params[:headers] || {})
            ), &block)
          rescue Excon::Errors::HTTPStatusError => error
            raise case error
                  when Excon::Errors::NotFound
                    Fog::OracleCloud::SOA::NotFound.slurp(error)
                  else
                    error
            end
          end
          if !response.body.empty? && parse_json
            # The Oracle Cloud doesn't return the Content-Type header as application/json, rather as application/vnd.com.oracle.oracloud.provisioning.Pod+json
            # Should add check here to validate, but not sure if this might change in future
            response.body = Fog::JSON.decode(response.body)
         end
          response
        end
      end

      class Mock
        def initialize(options = {})
          @username = options[:oracle_username]
          @password = options[:oracle_password]
          @identity_domain = options[:oracle_domain]
          @region_url = options[:oracle_region] == 'emea' ? 'https://jcs.emea.oraclecloud.com' : 'https://jaas.oraclecloud.com'
        end

        attr_reader :username

        attr_reader :password

        def self.data
          @data ||= {
            instances: {},
            servers: {},
            deleted_at: {},
            created_at: {}
          }
        end

        def self.reset
          @data = nil
        end

        def data
          self.class.data
        end
      end
    end
  end
end
