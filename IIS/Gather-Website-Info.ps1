#Gather IIS Website Information

import-module WebAdministration

Foreach ($Site in get-website){
    Foreach ($Bind in $Site.bindings.collection){
        [pscustomobject]@{
            Name=$Site.Name;
            Protocol=$Bind.Protocol;
            Bindings=$Bind.BindingInformation;
            Cert=$Bind.certificateHash;
            Path=$Site.PhysicalPath;
            AppPool=$Site.ApplicationPool;
        }
    }
}
