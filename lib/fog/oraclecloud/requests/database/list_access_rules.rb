module Fog
  module OracleCloud
    class Database
      class Real
        def list_access_rules(db_name)
          response = request(
            expects: 200,
            method: 'GET',
            path: "/paas/api/v1.1/instancemgmt/#{@identity_domain}/services/dbaas/instances/#{db_name}/accessrules"
          )
          response
        end
      end

      class Mock
        def list_access_rules(db_name)
          response = Excon::Response.new

          data[:access_rules][db_name] = [] unless data[:access_rules][db_name]
          access_rules = data[:access_rules][db_name]

          response.body = {
            'accessRules' => access_rules
          }
          response
        end
      end
    end
  end
end
