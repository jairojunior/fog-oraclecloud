module Fog
  module Compute
    class OracleCloud
      class Real
        def get_ip_association(name)
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''
          response = request(
            expects: 200,
            method: 'GET',
            path: "/ip/association/Compute-#{@identity_domain}/#{@username}/#{name}",
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json',
              'Accept' => 'application/oracle-compute-v3+json'
            }
          )
          response
        end
      end

      class Mock
        def get_ip_association(name)
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''
          if ip = data[:ip_associations][clean_name]
            response.status = 200
            response.body = ip
            response
          else
            raise Fog::Compute::OracleCloud::NotFound, "IP Association #{name} does not exist"
          end
        end
      end
    end
  end
end
