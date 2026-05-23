# Arborisis — Nginx Production
# Sert les assets statiques et fait reverse-proxy vers PHP-FPM
# =============================================================================

FROM nginx:alpine

LABEL org.opencontainers.image.title="arborisis-nginx"
LABEL org.opencontainers.image.description="Arborisis Nginx reverse proxy"
LABEL org.opencontainers.image.source="https://github.com/Arborisis/infrastructure"

# Supprimer la config par défaut
RUN rm /etc/nginx/conf.d/default.conf

# Copier la configuration Arborisis
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Créer les répertoires pour les logs et le cache
RUN mkdir -p /var/cache/nginx /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
