# Nginx-on-dotcloud

Custom nginx install on dotcloud based on [tengine](https://github.com/alibaba/tengine/)

## How to use

1. clone this repo
2. make any changes you need
3. dotcloud create <app_name>
4. cd into the nginx-on-dotcloud directory
5. dotcloud push <app_name> .


## Config

Before you push the nginx server you need to set the following env vars:

- ``ACCESS_APP_ID`` Github client id
- ``ACCESS_APP_SECRET`` Github client secret
- ``ACCESS_ORG`` Github org to allow to access the app

You set these values on your instance by as such. You may also put them in your dotcloud.yml file but that is not recommended.

``` bash
dotcloud env set \
    'ACCESS_APP_ID=6dd82fd5a64a6f1acd9f912bcbe40004' \
    'ACCESS_APP_SECRET=72fc1bf55b68d649bcd9c53a7d3a857156b24fb5' \
    'ACCESS_ORG=disqus'
```

If you need to change the way nginx is compiled, then you will need to look in the ``nginx/builder`` file. Add any more modules or configuration options to the `CONFIGOPTS` variable.

If you need to change the nginx config, then you need to edit ``/nginx/nginx.conf.in``. I don't really recommend doing this off the bat, the system is a little fragile.

## How it works

When the custom service starts up it runs the ``nginx/builder`` file which compiles nginx and puts everything where it needs to be.

During deployment to the host the ``postinstall`` script will be run, and it will add the HTTP Port that it was assigned to the ``nginx.conf.in`` file.

It will then be started up, and if all went well you should be able to start seeing pages served from nginx.

# Static content

It will serve everything up under the ``static`` directory since it treats that directory as the root directory.


# rebuilding nginx

To speed things up, it will only compile nginx once, if it has a good compile, it will always use that going forward. If you want to do recompile of nginx after this, you will need to edit the ``nginx/builder`` file and uncomment step 1A at the bottom of the file.
