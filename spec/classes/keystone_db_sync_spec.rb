require 'spec_helper'

describe 'keystone::db::sync' do

  shared_examples_for 'keystone-dbsync' do

    describe 'with only required params' do
      it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage  db_sync',
          :path        => '/usr/bin',
          :user        => 'keystone',
          :try_sleep   => 5,
          :tries       => 10,
          :refreshonly => true,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
          :tag         => ['keystone-exec', 'openstack-db'],
        )
      }
    end

    describe "overriding extra_params and keystone user" do
      let :params do
        {
          :extra_params  => '--config-file /etc/keystone/keystone.conf',
          :keystone_user => 'test_user',
        }
      end

      it {
        is_expected.to contain_exec('keystone-manage db_sync').with(
          :command     => 'keystone-manage --config-file /etc/keystone/keystone.conf db_sync',
          :path        => '/usr/bin',
          :user        => 'test_user',
          :try_sleep   => 5,
          :tries       => 10,
          :refreshonly => true,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[keystone::install::end]',
                          'Anchor[keystone::config::end]',
                          'Anchor[keystone::dbsync::begin]'],
          :notify      => 'Anchor[keystone::dbsync::end]',
          :tag         => ['keystone-exec', 'openstack-db'],
        )
      }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'keystone-dbsync'
    end
  end

end
