# Security Checklist

- [ ] Enforce HTTPS on Config Server (TLS certificate, reverse proxy or Spring Boot SSL).
- [ ] Use Git deploy keys or GitHub App with least privilege to access config repo.
- [ ] Replace default credentials (`config/config123`) with secrets from Docker/Kubernetes Secrets.
- [ ] Restrict `/actuator/refresh` to internal networks or authenticated roles.
- [ ] Enable commit signing on config repository.
- [ ] Add secret scanning (e.g., `pre-golive.sh` or GitHub Advanced Security).
