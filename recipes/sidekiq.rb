# verify ruby dependency
verify_ruby 'Sidekiq - Ruby Plugin'

# check required attributes
verify_attributes do
  attributes [
                 'node[:newrelic][:sidekiq][:install_path]',
                 'node[:newrelic][:sidekiq][:namespace]',
                 'node[:redis_yml][:app2redis_database]',
                 'node[:db_host]'
             ]
end

node[:applications].each do |app_name,data|
  user = node[:users].first

  data[:components].each do |component|
    if component[:collection]
      component[:collection].each do |add_on|
        if add_on[:name] =~ /New Relic/
          license_key = add_on[:config][:vars][:license_key]
        end
      end
    end
  end

  if license_key
    verify_license_key license_key

    case node[:instance_role]
      when "solo", "app_master"
        install_plugin 'newrelic_sidekiq_plugin' do
          plugin_version   node[:newrelic][:sidekiq][:version]
          install_path     node[:newrelic][:sidekiq][:install_path]
          plugin_path      node[:newrelic][:sidekiq][:plugin_path]
          download_url     node[:newrelic][:sidekq][:download_url]
          user             user[:username]
        end

        # newrelic template
        template "#{node[:newrelic][:sidekiq][:plugin_path]}/config/newrelic_plugin.yml" do
          source 'sidekiq/newrelic_plugin.yml.erb'
          action :create
          owner user[:username]
          group user[:username]
          mode 0744
          notifies :restart, "service[newrelic-sidekiq-plugin-#{app_name}]"
          variables({
                        :app_name => app_name,
                        :uri => "redis://#{node[:db_host]}/#{node[:redis_yml][:app2redis_database][app_name]}",
                        :namespace => node[:newrelic][:sidekiq][:namespace]
                    })
        end

        # install bundler gem and run 'bundle install'
        bundle_install do
          path node[:newrelic][:sidekiq][:plugin_path]
          user user[:username]
        end

        # install init.d script and start service
        plugin_service "newrelic-sidekiq-plugin-#{app_name}" do
          daemon          './newrelic_sidekiq_agent'
          daemon_dir      node[:newrelic][:sidekiq][:plugin_path]
          plugin_name     'Sidekiq'
          plugin_version  node[:newrelic][:sidekiq][:version]
          user            user[:username]
          run_command     'bundle exec'
        end
    end
  end
end
