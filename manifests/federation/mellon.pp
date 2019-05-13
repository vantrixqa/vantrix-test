# == class: keystone::federation::mellon
#
# == Parameters
#
# [*methods*]
#  A list of methods used for authentication separated by comma or an array.
#  The allowed values are: 'external', 'password', 'token', 'oauth1', 'saml2',
#  and 'openid'
#  (Required) (string or array value).
#  Note: The external value should be dropped to avoid problems.
#
# [*idp_name*]
#  The name name associated with the IdP in Keystone.
#  (Required) String value.
#
# [*protocol_name*]
#  The name for your protocol associated with the IdP.
#  (Required) String value.
#
# [*template_order*]
#  This number indicates the order for the concat::fragment that will apply
#  the shibboleth configuration to Keystone VirtualHost. The value should
#  The value should be greater than 330 an less then 999, according to:
#  https://github.com/puppetlabs/puppetlabs-apache/blob/master/manifests/vhost.pp
#  The value 330 corresponds to the order for concat::fragment  "${name}-filters"
#  and "${name}-limits".
#  The value 999 corresponds to the order for concat::fragment "${name}-file_footer".
#  (Optional) Defaults to 331.
#
# [*package_ensure*]
#   (optional) Desired ensure state of packages.
#   accepts latest or specific versions.
#   Defaults to present.
#
# [*enable_websso*]
#   (optional) Wheater or not to enable Web Single Sign-On (SSO)
#   Defaults to false
#
# === DEPRECATED
#
# [*trusted_dashboards*]
#   (optional) URL list of trusted horizon servers.
#   This setting ensures that keystone only sends token data back to trusted
#   servers. This is performed as a precaution, specifically to prevent man-in-
#   the-middle (MITM) attacks.
#   It is recommended to use the keystone::federation class to set the
#   trusted_dashboards configuration instead of this parameter.
#   Defaults to undef
#
# [*admin_port*]
#  A boolean value to ensure that you want to configure K2K Federation
#  using Keystone VirtualHost on port 35357.
#  (Optional) Defaults to undef.
#
# [*main_port*]
#  A boolean value to ensure that you want to configure K2K Federation
#  using Keystone VirtualHost on port 5000.
#  (Optional) Defaults to undef.
#
class keystone::federation::mellon (
  $methods,
  $idp_name,
  $protocol_name,
  $template_order     = 331,
  $package_ensure     = present,
  $enable_websso      = false,
  # DEPRECATED
  $trusted_dashboards = undef,
  $admin_port         = undef,
  $main_port          = undef,
) {

  include ::apache
  include ::keystone::deps
  include ::keystone::params

  if ($trusted_dashboards) {
    warning("keystone::federation::mellon::trusted_dashboards is deprecated \
in Stein and will be removed in future releases")
  }

  if $admin_port or $main_port {
    warning('keystone::federation::mellon::admin_port and main_port are deprecated and have no effect')
  }

  # Note: if puppet-apache modify these values, this needs to be updated
  if $template_order <= 330 or $template_order >= 999 {
    fail('The template order should be greater than 330 and less than 999.')
  }

  if ('external' in $methods ) {
    fail("The external method should be dropped to avoid any interference with some \
Apache + Mellon SP setups, where a REMOTE_USER env variable is always set, even as an empty value.")
  }

  if !('saml2' in $methods ) {
    fail('Methods should contain saml2 as one of the auth methods.')
  }

  validate_legacy(Boolean, 'validate_bool', $enable_websso)

  keystone_config {
    'auth/methods': value  => join(any2array($methods),',');
    'auth/saml2':   ensure => absent;
  }

  if($enable_websso){
    if($trusted_dashboards){
      keystone_config {
        'federation/trusted_dashboard': value => join(any2array($trusted_dashboards),',');
      }
    }
    keystone_config {
      'mapped/remote_id_attribute': value => 'MELLON_IDP';
    }
  }

  ensure_packages([$::keystone::params::mellon_package_name], {
    ensure => $package_ensure,
    tag    => 'keystone-support-package',
  })

  concat::fragment { 'configure_mellon_keystone':
    target  => "${keystone::wsgi::apache::priority}-keystone_wsgi.conf",
    content => template('keystone/mellon.conf.erb'),
    order   => $template_order,
  }

}
