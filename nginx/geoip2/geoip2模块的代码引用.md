# geoip2模块的引用方法

## 代码

```shell
http{   
    map $arg_ip $http_x_real_ip {
        default "";
        ~^(?<ip>.+)$ $arg_ip;
    }
    map $arg_lang $lang {
        default "";
        ~^(?<lang>.+)$ $arg_lang;
    }

    geoip2 /etc/nginx/geoip2/GeoLite2-City.mmdb {
	auto_reload 1d;
        #国家
        $geoip_country_name_de  source=$http_x_real_ip country names de;
        $geoip_country_name_en  source=$http_x_real_ip country names en;
        $geoip_country_name_es  source=$http_x_real_ip country names es;
        $geoip_country_name_fr  source=$http_x_real_ip country names fr;
        $geoip_country_name_ja  source=$http_x_real_ip country names ja;
        $geoip_country_name_ptBR  source=$http_x_real_ip country names pt-BR;
        $geoip_country_name_ru  source=$http_x_real_ip country names ru;
        $geoip_country_name_zhCN  source=$http_x_real_ip country names zh-CN;

        #城市
        $geoip_city_name_de  source=$http_x_real_ip city names de;
        $geoip_city_name_en  source=$http_x_real_ip city names en;
        $geoip_city_name_es  source=$http_x_real_ip city names es;
        $geoip_city_name_fr  source=$http_x_real_ip city names fr;
        $geoip_city_name_ja  source=$http_x_real_ip city names ja;
        $geoip_city_name_ptBR  source=$http_x_real_ip city names pt-BR;
        $geoip_city_name_ru  source=$http_x_real_ip city names ru;
        $geoip_city_name_zhCN  source=$http_x_real_ip city names zh-CN;

        #省份
        $geoip_subdivisions_de source=$http_x_real_ip subdivisions 0 names de;
        $geoip_subdivisions_en source=$http_x_real_ip subdivisions 0 names en;
        $geoip_subdivisions_es source=$http_x_real_ip subdivisions 0 names es;
        $geoip_subdivisions_fr source=$http_x_real_ip subdivisions 0 names fr;
        $geoip_subdivisions_ja source=$http_x_real_ip subdivisions 0 names ja;
        $geoip_subdivisions_ptBR source=$http_x_real_ip subdivisions 0 names pt-BR;
        $geoip_subdivisions_ru source=$http_x_real_ip subdivisions 0 names ru;
        $geoip_subdivisions_zhCN source=$http_x_real_ip subdivisions 0 names zh-CN;

        #注册国家
        $geoip_registered_country_geoname_id source=$http_x_real_ip registered_country geoname_id;
        $geoip_registered_country_iso_code source=$http_x_real_ip registered_country iso_code;


        #经纬度
        $geoip_location_time_zone  source=$http_x_real_ip location time_zone;
	    $geoip_location_latitude  source=$http_x_real_ip location latitude;
	    $geoip_location_longitude  source=$http_x_real_ip location longitude;

        #洲
        $geoip_continent_code  source=$http_x_real_ip continent code;
        $geoip_continent_name  source=$http_x_real_ip continent names en;
}
    
server{
    listen 80;
    server_name api.voov.cc.conf;
    location /ipinfo/geoip  {
        set $lang $arg_lang;
        # set $length 500;
        # add_header Content-Length $length;
        # add_header Content-Type application/json;
        # default_type application/json;
    

        if ( $lang = ''){
            return 200 "{
	\"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_en\",
    \"city\":\"$geoip_city_name_en\",
    \"province\":\"$geoip_subdivisions_en\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
	}

        if ( $lang = 'de'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_zhCN\",
    \"city\":\"$geoip_city_name_de\",
    \"province\":\"$geoip_subdivisions_de\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'en'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_en\",
    \"city\":\"$geoip_city_name_en\",
    \"province\":\"$geoip_subdivisions_en\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'es'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_es\",
    \"city\":\"$geoip_city_name_es\",
    \"province\":\"$geoip_subdivisions_es\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'fr'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_fr\",
    \"city\":\"$geoip_city_name_fr\",
    \"province\":\"$geoip_subdivisions_fr\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'ja'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_ja\",
    \"city\":\"$geoip_city_name_ja\",
    \"province\":\"$geoip_subdivisions_ja\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'pt-BR'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_ptBR\",
    \"city\":\"$geoip_city_name_ptBR\",
    \"province\":\"$geoip_subdivisions_ptBR\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'ru'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_ru\",
    \"city\":\"$geoip_city_name_ru\",
    \"province\":\"$geoip_subdivisions_ru\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
        if ( $lang = 'zh-CN'){
            return 200 "{
    \"ip_address\":\"$http_x_real_ip\",
    \"country\":\"$geoip_country_name_zhCN\",
    \"city\":\"$geoip_city_name_zhCN\",
    \"province\":\"$geoip_subdivisions_zhCN\",
    \"registered_country_geoname_id\":\"$geoip_registered_country_geoname_id\",
    \"iso_code\":\"$geoip_registered_country_iso_code\",
    \"time_zone\":\"$geoip_location_time_zone\",
    \"latitude\":\"$geoip_location_latitude\",
    \"longitude\":\"$geoip_location_longitude\",
    \"continent_name\":\"$geoip_continent_name\",
    \"continent_code\":\"$geoip_continent_code\"
}";
        }
    }
}


}
```

