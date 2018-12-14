# srv-gateway

Dockerized NGINX based gateway with automatic routing based off on service discovery with Consul.

This service autodetects whenever a service leaves or join the cluster. On detection it looks for a tag, "platform-endpoint". For all services with said tag, is considered a part of the dm848 microservice platform and becomes exposed at http://domain/api/{SERVICE-NAME}/ within 30 seconds.
