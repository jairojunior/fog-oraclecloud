module Fog
  module OracleCloud
    class Database
      class Real
        def list_recoveries(db_name)
          response = request(
            expects: 200,
            method: 'GET',
            path: "/paas/service/dbcs/api/v1.1/instances/#{@identity_domain}/#{db_name}/backups/recovery/history"
          )
          response
        end
      end

      class Mock
        def list_recoveries(db_name)
          response = Excon::Response.new

          data[:recoveries][db_name] = [] unless data[:recoveries][db_name]
          recoveries = data[:recoveries][db_name]

          recoveries.each_with_index do |r, i|
            next unless r['status'] = 'IN PROGRESS'
            next unless Time.now - data[:created_at][:recoveries][db_name][i] >= Fog::Mock.delay
            data[:created_at][:recoveries][db_name].delete(i)
            data[:recoveries][db_name][i]['status'] = 'COMPLETED'
            data[:recoveries][db_name][i]['recoveryCompleteDate'] = Time.now.strftime('%d-%b-%Y %H:%M:%S UTC')
            b = data[:backups][db_name][i]
          end
          response.body = {
            'recoveryList' => recoveries
          }
          response
        end
      end
    end
  end
end
