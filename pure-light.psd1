@{
  RootModule        = 'pure-light.psm1'
  ModuleVersion     = '0.1.0'
  GUID              = 'c0906cb2-b8de-4323-b3a8-a517cf5bc8eb'

  Author            = 'Phoe Lycia'
  Copyright         = '(c) Nick Cox. All rights reserved.'
  Description       = 'pure prompt for powershell'
  PowerShellVersion = '5.1'

  VariablesToExport = 'pure'

  PrivateData       = @{
    PSData = @{
      Tags       = @('pure', 'prompt')
      LicenseUri = 'https://github.com/nickcox/pure-pwsh/blob/master/LICENSE'
      ProjectUri = 'https://github.com/PhoeLycia/pure-light'
    }
  }
}
