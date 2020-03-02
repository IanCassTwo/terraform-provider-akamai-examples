for i in `ls microservices`
do
terraform import module.$i.module.gtm.akamai_gtm_domain.iancass_co_uk_akadns_net iancass.co.uk.akadns.net
terraform import module.$i.module.gtm.akamai_gtm_datacenter.Frankfurt iancass.co.uk.akadns.net:3133 
terraform import module.$i.module.gtm.akamai_gtm_datacenter.Dublin iancass.co.uk.akadns.net:3134 
done
