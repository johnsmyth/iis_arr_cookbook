name             'iis_arr'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures iis_arr'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports         'windows'
depends          'windows', '= 1.30.0'
depends          'webpi'    #, '~> 1.2.8'
####depends          'minitest-handler', '~> 1.1.2'
depends          'iis'    #, '~> 1.5.4'
