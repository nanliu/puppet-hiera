# Class: hiera
#
#   This module configures hiera on puppet master.
#
# Parameters:
#
#   [*version*]: gem or package version accepts present, latest.
#   [*provider*]: hiera, hiera-puppet package provider.
#   [*owner*]: hiera.yaml file owner.
#   [*group*]: hiera.yaml file group.
#   [*mode*]: hiera.yaml file mode.
#   [*source*]: hiera.yaml file source. Please use seperate data module for custom yaml file (see usage).
#   [*template*]: hiera.yaml template file. Please use seperate data module for custom yaml template (see usage).
#   [*replace*]: whether to replace hiera.yaml after initial deployment.
#   [*confdir*]: puppet confdir, typically /etc/puppet for opensource, /etc/puppetlabs/puppet for PE.
#   [*modulepath*]: puppet modulepath, typically /etc/puppet/modules for opensource, /etc/puppetlabs/puppet/modules for PE.
#   [*dependency*]: whether or not the module will install dependant packages.
#   [*install_method*]: the installation method for hiera-puppet module (git, pmt, face, stub).
#
# Requires:
#
#   None. Stdlibs dependency will enhance validation, but no dependency to simplify installation.
#
# Usage:
#
#  class { 'hiera':
#    source     => 'puppet:///modules/acme/hiera.yaml',
#    replace    => true,
#    dependency => false,
#  }
#
#  class { 'hiera':
#    template   => 'acme/hiera.yaml.erb',
#    dependency => false,
#  }
#
class hiera (
  $version        = present,
  $provider       = $hiera::data::provider,
  $owner          = $hiera::data::owner,
  $group          = $hiera::data::group,
  $mode           = $hiera::data::mode,
  $source         = $hiera::data::source,
  $template       = undef,
  $replace        = false,
  $confdir        = $hiera::data::confdir,
  $modulepath     = $hiera::data::modulepath,
  $dependency     = true,
  $install_method = 'git',
) inherits hiera::data {

  package { 'hiera':
    ensure   => $version,
    provider => $provider,
  }

  package { 'hiera-puppet':
    ensure   => $version,
    provider => $provider,
  }

  if $template {
    $r_source  = undef
    $r_content = template($template)
  } else {
    $r_source  = $source
    $r_content = undef
  }

  file { "${confdir}/hiera.yaml":
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $r_source,
    content => $r_content,
    replace => $replace,
  }

  case $install_method {
    'git': {
      $command = 'git clone git://github.com/puppetlabs/hiera-puppet'

      if $dependency {
        package { 'git':
          ensure => present,
          before => Exec['hiera-puppet'],
        }
      }
    }
    'pmt': {
      $command = 'puppet-module install hiera-puppet'

      if $dependency and ($::hiera::data::target == 'opensource') {
        package { 'puppet-module':
          ensure   => present,
          provider => $provider,
          before   => Exec['hiera-puppet'],
        }
      }
    }
    'face': {
      $command = 'puppet module install hiera-puppet'
    }
    'stub': {
      $command = "touch ${modulepath}/hiera-puppet"
    }
    'none': {
      $command = 'echo "Another resource should install hiera-puppet modules"'
    }
  }

  exec { 'hiera-puppet':
    command => $command,
    cwd     => $modulepath,
    path    => '/usr/local/bin:/usr/bin:/bin',
    creates => "${modulepath}/hiera-puppet",
  }

}
