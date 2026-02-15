# Charger les protocoles de base
@load base/frameworks/notice
@load base/protocols/conn
@load base/protocols/dns
@load base/protocols/http
@load base/protocols/ssl
@load base/protocols/ssh
@load base/protocols/smtp
@load base/protocols/ftp

# Charger les politiques de détection
@load policy/frameworks/notice/actions/add-geodata
@load policy/protocols/conn/known-hosts
@load policy/protocols/conn/known-services
@load policy/protocols/dns/detect-external-names
@load policy/protocols/http/detect-sqli
@load policy/protocols/http/detect-webapps

# Configuration réseau
redef Site::local_nets = {
    192.168.0.0/16,
    10.0.0.0/8,
    172.16.0.0/12
};

# Configuration logs
redef Log::default_rotation_interval = 1hr;
redef Log::default_logdir = "/data/logs/zeek/current";

# Logs au format TSV (natif Zeek, pas JSON)
# Logstash se charge de la transformation

# Détections personnalisées
event connection_established(c: connection) {
    # Détection de connexions suspectes
    if (c$id$resp_p == 22/tcp && c$orig$location$country_code !in Site::local_zones) {
        NOTICE([$note=SSH_From_Foreign_Country,
                $msg=fmt("SSH connection from %s", c$id$orig_h),
                $conn=c]);
    }
}

# Extraction de fichiers
@load base/files/extract
redef FileExtract::prefix = "/data/extracted-files/";
redef FileExtract::default_limit = 10MB;
