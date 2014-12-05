ey_cloud_report "newrelic-sidekiq-agent" do
  message "Setting up NewRelic sidekiq agent"
end

# verify ruby dependency
verify_ruby 'Sidekiq - Ruby Plugin'

# check required attributes
verify_attributes do
  attributes [
                 'node[:newrelic][:sidekiq][:download_url]',
                 'node[:newrelic][:sidekiq][:install_path]',
                 'node[:newrelic][:sidekiq][:namespace]',
                 'node[:newrelic][:sidekiq][:plugin_path]',
                 'node[:newrelic][:sidekiq][:version]',
                 'node[:redis_yml][:app2redis_database]',
                 'node[:db_host]',
                 'node[:users]',
                 'node[:engineyard][:environment][:apps]',
                 'node[:environment][:framework_env]'
             ]
end

user = node[:users].first

node[:engineyard][:environment][:apps].each do |app|

  app_name = app[:name]
  app_license_key app
  license_key = node[:newrelic][app_name][:license_key]

  if license_key

    case node[:instance_role]
      when "solo", "app_master"
        install_plugin 'newrelic_sidekiq_plugin' do
          plugin_version   node[:newrelic][:sidekiq][:version]
          install_path     node[:newrelic][:sidekiq][:install_path]
          plugin_path      node[:newrelic][:sidekiq][:plugin_path]
          download_url     node[:newrelic][:sidekiq][:download_url]
          user             user[:username]
        end

        # newrelic template
        template "#{node[:newrelic][:sidekiq][:plugin_path]}/config/newrelic_plugin.yml" do
          source 'sidekiq/newrelic_plugin.yml.erb'
          action :create
          owner user[:username]
          group user[:username]
          mode 0744
          #notifies :restart, "service[newrelic-sidekiq-plugin-#{app_name}]"
          notifies :run, resources(:execute => "restart-newrelic-sidekiq-agent-for-#{app_name}")
          variables({
                        :app_name => app_name,
                        :environment => node[:environment][:framework_env],
                        :uri => "redis://#{node[:db_host]}/#{node[:redis_yml][:app2redis_database][app_name]}",
                        :namespace => node[:newrelic][:sidekiq][:namespace],
                        :license_key => license_key
                    })
        end

        # install bundler gem and run 'bundle install'
        bundle_install do
          path node[:newrelic][:sidekiq][:plugin_path]
          user user[:username]
        end

        # install init.d script and start service
        # plugin_service "newrelic-sidekiq-plugin-#{app_name}" do
        #   daemon          './newrelic_sidekiq_agent'
        #   daemon_dir      node[:newrelic][:sidekiq][:plugin_path]
        #   plugin_name     'Sidekiq'
        #   plugin_version  node[:newrelic][:sidekiq][:version]
        #   user            user[:username]
        #   run_command     'bundle exec'
        # end

        # reload monit
        execute "restart-newrelic-sidekiq-agent-for-#{app_name}" do
          command "monit reload && sleep 1 && monit restart all -g <%= @app_name %>_sidekiq_newrelic_agent"
          action :nothing
        end

        # monit
        template "/etc/monit.d/newrelic_sidekiq_agent_#{app_name}.monitrc" do
          mode 0644
          source "sidekiq.monitrc.erb"
          backup false
          variables({
                        :app_name => app_name,
                        :rails_env => node[:environment][:framework_env],
                        :plugin_path => node[:newrelic][:sidekiq][:plugin_path],
                        :memory_limit => 200 # MB
                    })
          notifies :run, resources(:execute => "restart-newrelic-sidekiq-agent-for-#{app_name}")
        end
    end
  end
end
