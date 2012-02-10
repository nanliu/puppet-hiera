# Class: hiera::data
#
#  This is this data class
#
class hiera::data {

  if $::puppetversion =~ /Puppet Enterprise/ {
    $owner    = 'pe-puppet'
    $group    = 'pe-puppet'
    $provider = 'pe_gem'
    $target   = 'PE'
  } else {
    $owner    = 'puppet'
    $group    = 'puppet'
    $provider = 'gem'
    $target   = 'opensource'
  }

  $mode       = '0644'
  $source     = 'puppet:///modules/${module_name}/hiera.yaml'
  $version    = present
  $confdir    = inline_template("<%= Puppet[:confdir] %>")
  $modulepath = inline_template("<%= Puppet[:modulepath].split(':').first %>")

}
