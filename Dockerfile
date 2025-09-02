FROM nginx:alpine

# Static server for the MVP app
EXPOSE 8080

# Nginx config and static assets
COPY nginx.conf /etc/nginx/conf.d/default.conf
# GitHub Pages に合わせ docs/ を配信元にする
COPY docs/ /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
