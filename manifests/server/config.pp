# Private class
#
# @summary Encapsulates all configuration of the CUPS server
#
# This class inherits the several attributes from the public {cups} class.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly declared e.g. through
#   class { '::cups':
#     listen        => 'localhost:631',
#     papersize     => 'A4',
#     web_interface => true
#   }
#
class cups::server::config inherits cups::server {

  File {
    owner => 'root',
    group => 'lp'
  }

  concat { '/etc/cups/lpoptions':
    owner => 'root',
    mode  => '0644',
  }

  concat::fragment{ 'lpoptions_header':
    target  => '/etc/cups/lpoptions',
    content => "# This file is managed by puppet - please make changes there\n",
    order   => '01',
  }

  file { '/etc/cups/cupsd.conf':
    ensure  => 'file',
    mode    => '0640',
    content => template('cups/header.erb', 'cups/cupsd.conf.erb'),
  }

  if ($::cups::papersize) {
    exec { 'cups::papersize':
      command => "paperconfig -p ${::cups::papersize}",
      unless  => "cat /etc/papersize | grep -w ${::cups::papersize}",
      path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
    }
  }

}


define cups::lpoptions::register(
  String $content = "",
  String $order   = '10',
) {
  if $content == '' {
    $body = $name
  } else {
    $body = $content
  }

  concat::fragment{ "lpoptions_fragment_$name":
    target  => '/etc/cups/lpoptions',
    order   => $order,
    content => $content,
  }
}
