# Nginx-on-dotcloud

Custom nginx install on dotcloud based on nginx, but mainly [openresty](http://openresty.org/)

## How to use

1. clone this repo
2. make any changes you need
3. dotcloud create <app_name>
4. cd into the nginx-on-dotcloud directory
5. dotcloud push <app_name> .


## Persona Config (default)

Before you push the nginx server you need to set the following env vars:

- ``WHITELIST_DOMAINS`` a lua table of domains to whitelist

Ok, but wtfbbq is a lua table? Well, the one I test with looks like this:

    dotcloud env set 'WHITELIST_DOMAINS={
        ["disqus.com"] = true,
        ["disqus.net"] = true,
        ["northisup.com"] = true,
    }'

You set these values on your instance by as such. You may also put them in your dotcloud.yml file but that is not recommended.

## OAuth Plugin dependency

- https://github.com/openresty/lua-resty-core
- https://github.com/bungle/lua-resty-session
- https://github.com/brunoos/luasec 0.4.1+ (for ssl.https), 0.4.0 - untested.
- luajit 2.1 (2.0 - untested, because 2.1 is recomended by nginx-lua plugin and openresty)

## OAuth Config (hack the files)

!!! right now to enable oauth you will need to edit the postinstall script

Before you push the nginx server you need to set the following env vars:

- ``ACCESS_APP_ID`` Github client id
- ``ACCESS_APP_SECRET`` Github client secret
- ``ACCESS_ORG`` Github org to allow to access the app

 You set these values on your instance by as such. You may also put them in your dotcloud.yml file but that is not recommended.

    dotcloud env set \
        'ACCESS_APP_ID=6dd82fd5a64a6f1acd9f912bcbe40004' \
        'ACCESS_APP_SECRET=72fc1bf55b68d649bcd9c53a7d3a857156b24fb5' \
        'ACCESS_ORG=disqus'

## OAuth exported variables

OAuth sets variable ``auth_user`` and ``auth_email`` with user's login and email (if availabe, otherwise they are set to "unknown"). You can use this variables inside your application:

    location / {
        set $auth_user 'unknwon';
        set $auth_email 'unknown';
        lua_need_request_body on;
        access_by_lua_file "/etc/nginx/oauth.lua";
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param AUTH_USER $auth_user;
        fastcgi_param REMOTE_USER $auth_user;
        fastcgi_param AUTH_EMAIL $auth_email;
    }

## Nginx compilation and customization

tl;dr `nginx/builder -h`

The current build script supports a few versions of nginx and uses openresty by default.

- vanilla nginx
- tengine nginx
- openresty nginx

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
