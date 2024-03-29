


provider "aws" {
  #access_key = "${var.AWS_ACCESS_KEY}"
  #secret_key = "${var.AWS_SECRET_KEY}"
  region = "${var.AWS_REGION}"
  profile = "${var.aws_profile}"

}

##----------------------------
#     Get VPC Variables
##----------------------------

#-- Get VPC ID
#data "aws_vpc" "selected" {
#  id = "${var.vpc_cidr}"
#}

#-- Get Public Subnet List
#data "aws_subnet_ids" "selected" {
 # vpc_id = "${data.aws_vpc.selected.id}"

 # tags = {
  #  Tier = "public"
# }
#}

#--- Gets Security group with tag specified by var.name_tag
#data "aws_security_group" "selected" {
 # tags = {
 #   Name = "${var.name_tag}*"
#  }
#}


resource "aws_instance" "server" {
    ami           = "${data.aws_ami.windows.id}"
    instance_type = "t2.medium"
    private_ip = "10.25.16.6"
    key_name = "${var.KEY_PAIR}"
    subnet_id = "subnet-05a67d3cbee1bbc99"
    associate_public_ip_address  = "true"
    vpc_security_group_ids = ["${aws_security_group.SG-IIS.id}"]
    #id = "${data.aws_vpc.selected.id}"
    get_password_data    = "true"
    user_data = <<EOF
    <powershell>
    winrm quickconfig -q
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=”300″}'
    winrm set winrm/config '@{MaxTimeoutms=”1800000″}'
    winrm set winrm/config/service '@{AllowUnencrypted=”true”}'
    winrm set winrm/config/service/auth ‘@{Basic=”true”}’
    winrm set winrm/config/client '@{TrustedHosts="*"}'
    netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
    netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
    net stop winrm
    sc.exe config winrm start=auto
    net start winrm
    Install-WindowsFeature -name Web-Server -IncludeManagementTools
    Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses '10.25.20.4','10.25.22.4'
    net user Administrator "P@ssw0rd1234"
    $dnsCGSetting = Get-DnsClientGlobalSetting
    $dnsCGSetting.SuffixSearchList += "aws.sprue.com"
    Set-DnsClientGlobalSetting -SuffixSearchList $dnsCGSetting.SuffixSearchList
    $password = "Domainaccount123" | ConvertTo-SecureString -asPlainText -Force
    $username = "suppv"
    $credential = New-Object System.Management.Automation.PSCredential($username,$password)
    $hostname = "IIS-TEST"
    Add-Computer -domainname aws.sprue.com -OUPath "OU=IIS,OU=DMZ,OU=Computers,OU=sprue,DC=aws,DC=sprue,DC=com" -NewName $hostname -DomainCredential $credential -Passthru -Verbose -Force -Restart
    Start-Sleep -s 300
    #Add-Computer -DomainName $domain -OUPath \"$ouPath\" -Credential $credential\n
   # Add-Computer -DomainName "aws.sprue.com" -OUPath "OU=sprue,DC=aws,DC=sprue,DC=com" -DomainCredential $mycreds -Restart –Force
   # Start-Sleep -s 300
    </powershell>
    EOF
    root_block_device {
    volume_type           = "${var.volume_type}"
    volume_size           = "${var.volume_size}"
    delete_on_termination = "true"
      }
    
    tags = {
        Name = "new-iisserver"
      }
   connection {
         type     = "winrm"
         user     = "Administrator"
        # password = "P@ssword1234"
        # password = "${var.domain_password}"
         password = "${var.admin_password}"
     }
  # provisioner "local-exec" {
  #   command = "sleep 300"
#}
/*provisioner "remote-exec" {
    # command =  "Rename-Computer -NewName "IIS001" -DomainCredential Administrator/P@ssword1234 -Restart -Force"
     #interpreter = ["PowerShell", "-Command"]
   inline = [
           "powershell -Command \"&{Rename-Computer -NewName IIS001 -DomainCredential suppv\${var.domain_password} -Restart -Force}\""
     ]
       connection {
         type     = "winrm"
         user     = "Administrator"
         password = "P@ssword1234"
         #password = "Vinayaka"123"
        insecure = "true"
       # host = "35.180.134.73"  
     }
 }*/
}



    
 




   

