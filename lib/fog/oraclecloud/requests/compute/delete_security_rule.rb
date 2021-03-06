module Fog
  module Compute
    class OracleCloud
      class Real
        def delete_security_rule(name)
          # Just in case it's already set
          name.sub! "/Compute-#{@identity_domain}/#{@username}/", ''
          request(
            method: 'DELETE',
            expects: 204,
            path: "/secrule/Compute-#{@identity_domain}/#{@username}/#{name}",
            headers: {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
        end
      end
    end
  end
end
