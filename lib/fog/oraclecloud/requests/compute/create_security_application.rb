module Fog
  module Compute
    class OracleCloud
      class Real
        def create_security_application(name, protocol, options = {})
          body_data = {
            'name' => name,
            'protocol'						=> protocol,
            'dport'								=> options[:dport],
            'icmptype'						=> options[:icmptype],
            'icmpcode'						=> options[:icmpcode],
            'description'					=> options[:description]
          }
          body_data = body_data.reject { |_key, value| value.nil? }
          request(
            method: 'POST',
            expects: 201,
            path: '/secapplication/',
            body: Fog::JSON.encode(body_data),
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def create_security_application(name, protocol, _options = {})
          response = Excon::Response.new
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''

          data = {
            'name'                => "/Compute-#{@identity_domain}/#{@username}/#{name}",
            'protcol'             => protocol,
            'uri'                 => "#{@api_endpoint}seclist/#{name}"
          }
          self.data[:security_applications][name] = data

          response.status = 201
          response.body = self.data[:security_applications][name]
          response
        end
      end
    end
  end
end
