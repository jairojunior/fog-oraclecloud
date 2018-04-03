module Fog
  module Compute
    class OracleCloud
      class Real
        def create_security_ip_list(name, description, secipentries)
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''

          body_data = {
            'name'                => "/Compute-#{@identity_domain}/#{@username}/#{name}",
            'description'         => description,
            'secipentries'        => secipentries
          }
          body_data = body_data.reject { |_key, value| value.nil? }
          request(
            method: 'POST',
            expects: 201,
            path: '/seciplist/',
            body: Fog::JSON.encode(body_data),
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end

      class Mock
        def create_security_ip_list(name, description, secipentries)
          response = Excon::Response.new
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''

          data = {
            'name'                => "/Compute-#{@identity_domain}/#{@username}/#{name}",
            'description'         => description,
            'secipentries'        => secipentries,
            'uri'                 => "#{@api_endpoint}seclist/#{name}"
          }
          self.data[:security_ip_lists][name] = data

          response.status = 201
          response.body = self.data[:security_ip_lists][name]
          response
        end
      end
    end
  end
end
