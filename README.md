Aspace HTTPS PLUGIN
--------------------------

This plugin patches Net::HTTP.start to use_ssl if the port is either 443 or 8443.
This is needed if you're using SSL on Solr, for example. 

To use, put 'aspace-https' in you AppConfig[:plugins] list in the config.rb file.
Make sure that the port number ( 443 or 8443 ) are included in the URL used in your
configuration. i.e.:

```
AppConfig[:solr_url] = 'https://secure.solr.edu:443/solr'
```

