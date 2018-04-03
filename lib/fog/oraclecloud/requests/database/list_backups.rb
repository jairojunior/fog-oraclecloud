module Fog
  module OracleCloud
    class Database
      class Real
        def list_backups(db_name)
          response = request(
            expects: 200,
            method: 'GET',
            path: "/paas/service/dbcs/api/v1.1/instances/#{@identity_domain}/#{db_name}/backups"
          )
          response
        end
      end

      class Mock
        def list_backups(db_name)
          response = Excon::Response.new

          data[:backups][db_name] = [] unless data[:backups][db_name]
          backups = data[:backups][db_name]

          backups.each_with_index do |b, i|
            next unless b['status'] = 'IN PROGRESS'
            next unless Time.now - data[:created_at][:backups][db_name][i] >= Fog::Mock.delay
            data[:created_at][:backups][db_name].delete(i)
            data[:backups][db_name][i]['status'] = 'COMPLETED'
            b = data[:backups][db_name][i]
          end
          response.body = {
            'backupList' => backups
          }
          response
        end
      end
    end
  end
end
