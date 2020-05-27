# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include puppet_fnms_agent
class puppet_fnms_agent {

  case $facts['kernel'] {
    'windows': {
      file {'Flexera init file':
        ensure  => file,
        path    => "C:\\Windows\\Temp\\mgssetup.ini",
        content => epp('puppet_fnms_agent/mgssetup.ini.epp'),
        before  => Package['FlexNet Inventory Agent'],
      }

      package { 'FlexNet Inventory Agent':
        ensure   => 'installed',
        source   => 'C:\\Windows\\Temp\\FlexNetAgent.msi',
        provider => 'windows',
      }

      service { ['mgssecsvc', 'ndinit']:
        ensure => running,
        enable => true,
      }
    }
    'Linux': {
      $_provider = $facts['os']['family'] ? {
        'Debian'  => 'dpkg',
        default   => 'rpm',
      }

      file {'Flexera response file':
        ensure  => file,
        path    => '/var/tmp/mgsft_rollout_response',
        content => epp('puppet_fnms_agent/mgsft_rollout_response.epp'),
      }

      package { 'managesoft':
        ensure   => 'installed',
        source   => '/tmp/managesoft',
        provider => 'windows',
      }

      service { ['mgsusageag', 'ndtask']:
        ensure => running,
        enable => true,
      }

      exec { 'Force a policy update':
        command => '/opt/managesoft/bin/mgspolicy –t machine',
      }

      exec { ' Force and inventory scan':
        command => '/opt/managesoft/bin/ndtrack –t machine',
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
