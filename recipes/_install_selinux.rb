bash "semodule -i sshd_stat_authorized_keys.pp" do
  code <<-CODE
checkmodule -M -m -o sshd_stat_authorized_keys.mod sshd_stat_authorized_keys.te
semodule_package -o sshd_stat_authorized_keys.pp -m sshd_stat_authorized_keys.mod 
semodule -i sshd_stat_authorized_keys.pp
  CODE
  cwd "/tmp"
  action :nothing
end

cookbook_file "/tmp/sshd_stat_authorized_keys.te" do
  source "selinux/sshd_stat_authorized_keys.te"
  notifies :run, "bash[semodule -i sshd_stat_authorized_keys.pp]"
end

bash "semodule -i logshipper.pp" do
  code <<-CODE
    checkmodule -M -m -o logshipper.mod logshipper.te
    semodule_package -o logshipper.pp -m logshipper.mod -f logshipper.fc
    semodule -i logshipper.pp
    [ -p /var/run/logshipper ] && restorecon /var/run/logshipper
  CODE
  cwd "/tmp"
  action :nothing
end

cookbook_file "/tmp/logshipper.te" do
  source "selinux/logshipper.te"
  notifies :run, "bash[semodule -i logshipper.pp]"
end

cookbook_file "/tmp/logshipper.fc" do
  source "selinux/logshipper.fc"
  notifies :run, "bash[semodule -i logshipper.pp]"
end
