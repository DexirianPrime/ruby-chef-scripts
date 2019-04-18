module YpChefserver
  module LDAP
    require 'net-ldap'
    @ldap
    def get_ldap(ldap_password)
      if @ldap.nil?
        @ldap = Net::LDAP.new :host => "ad.ypg.com",
        :port => 389,
        :auth => {
              :method => :simple,
              :username => "CN=svc_openaudit,OU=East Service Accounts,OU=System Accounts,DC=ad,DC=ypg,DC=com",
              :password => "#{ldap_password}"
        }
      end
      @ldap
    end
    def get_ldap_users(ldap_password)
      filter = Net::LDAP::Filter.eq("cn", "DevOps")
      treebase = "dc=ad, dc=ypg, dc=com"
      get_ldap(ldap_password).search(:base => treebase, :filter => filter) do |entry|
       #puts "DN: #{entry.dn}"
       entry.each do |attribute, values|
		    return values if attribute == :member
       end
      end
    end
    def get_sam(ldap_password)
      samacc = Array.new
      get_ldap_users(ldap_password).entries.each{ |elem|
        y = elem.to_s.split(/[,=]/)
        filter = Net::LDAP::Filter.eq("cn", y[1])
        treebase = "DC=ad,DC=ypg,DC=com"
        get_ldap(ldap_password).search(:base => treebase, :filter => filter, :attributes => "SamAccountName") do |entry|
          samacc << entry.samaccountname
        end
      }
      return samacc
    end
    def get_attrs(ldap_password)
      data = Hash.new
      get_ldap_users(ldap_password).entries.each{ |elem|
        y = elem.to_s.split(/[,=]/)
        x = y[1]
        filter = Net::LDAP::Filter.eq("cn", x)
        treebase = "DC=ad,DC=ypg,DC=com"
        attrs = ["mail", "givenname", "sn", "SamAccountName"]
        get_ldap(ldap_password).search(:base => treebase, :filter => filter, :attributes => attrs) do |entry|
          if ! entry[:mail][0].nil?
            samid = entry.samaccountname[0].downcase
            data[samid] = Hash.new
            entry.each do |attribute, values|
       		    data[samid][attribute] = values[0]
            end
          end

        end
      }
      return data
    end
  end
end

