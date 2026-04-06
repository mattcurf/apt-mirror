FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-mirror cron xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/foreach ( split( \/\\n\/, $lines{"Files:"} ) )/my $files_field = defined $lines{"Files:"} ? $lines{"Files:"} : (defined $lines{"Checksums-Sha256:"} ? $lines{"Checksums-Sha256:"} : ""); foreach ( split( \/\\n\/, $files_field ) )/' /usr/bin/apt-mirror

COPY mirror.list /etc/apt/mirror.list
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
