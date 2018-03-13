# Performance tests

jMeter Performance tests for EEA WWW/KGS Plone sites

## Pre-requirements

* A running `Plone site` or
* Start Plone:

        $ docker run -d --name=kgs -p 8080:8080 eeacms/kgs

  * Add Plone Site
  * Create `sandbox` folder
  * Within `sandbox` create 2 folders: `folder1`, `folder2` and add some content within them.
  * Get your station IP address(e.g.: `$ ip addr`)
  * Export `IP` env:

        $ export IP=<my-ip-address>

## Rename

        $ jmeter -n -t rename.jmx \
                    -Jserver=$IP \
                    -Jport=8080 \
                    -Juser=admin \
                    -Jpassword=admin \
                    -Jsite=Plone \
                    -Jsandbox=sandbox \
                    -Jsource=folder1 \
                    -Jrepeat=1 \
                 -l /tmp/rename.csv
        $ tail -f /tmp/rename.csv

## Move

        $ jmeter -n -t move.jmx \
                    -Jserver=$IP \
                    -Jport=8080 \
                    -Juser=admin \
                    -Jpassword=admin \
                    -Jsite=Plone \
                    -Jsandbox=sandbox \
                    -Jsource=folder1 \
                    -Jdestination=folder2 \
                    -Jrepeat=1 \
                 -l /tmp/move.csv
        $ tail -f /tmp/move.csv

## Copy

        $ jmeter -n -t Copy.jmx \
                    -Jserver=$IP \
                    -Jport=8080 \
                    -Juser=admin \
                    -Jpassword=admin \
                    -Jsite=Plone \
                    -Jsandbox=sandbox \
                    -Jsource=folder1 \
                    -Jdestination=folder2 \
                    -Jrepeat=1 \
                 -l /tmp/copy.csv
        $ tail -f /tmp/copy.csv

## Record tests

* See [jMeter docs](http://jmeter.apache.org/usermanual/jmeter_proxy_step_by_step.html)
