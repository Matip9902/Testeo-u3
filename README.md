# Testeo-u3 - Innovatech SPA

Proyecto DevOps para desplegar una aplicacion compuesta por frontend, microservicios backend y base de datos relacional en AWS usando contenedores, Kubernetes y CI/CD.

## Colaboradores

- Benjamin Candia (`bjscripta`)
- Matias Imil (`Matip9902`)

## Tecnologias principales

- Frontend: React + Vite + Nginx
- Backend: Spring Boot 3.4.4
- Base de datos: MySQL 8.0
- Contenedores: Docker
- Orquestacion: Amazon EKS
- Registro de imagenes: Amazon ECR
- Infraestructura como codigo: Terraform
- CI/CD: GitHub Actions
- Autoscaling: Kubernetes HPA

## Estructura del proyecto

```text
Testeo-u3/
├── backend/
│   ├── Springboot-API-REST-VENTAS/
│   └── Springboot-API-REST-DESPACHO/
├── front_despacho/
├── infra/
│   ├── k8s/
│   ├── ecr.tf
│   ├── eks.tf
│   ├── grupo-seguridad.tf
│   ├── load-balancer.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── subredes.tf
│   ├── variables.tf
│   └── vpcs.tf
├── .github/workflows/
│   ├── ci.yml
│   └── cd.yml
├── docker-compose.yml
└── README.md
```

## Arquitectura

La infraestructura se crea con Terraform en AWS. Se define una VPC con dos subredes publicas en distintas zonas de disponibilidad, Internet Gateway, Route Table, Security Group, repositorios ECR y un cluster EKS llamado `innovatech-spa`.

La aplicacion se ejecuta sobre Kubernetes mediante los siguientes componentes:

- `frontend`: interfaz web expuesta mediante un Service tipo LoadBalancer.
- `backend-ventas`: microservicio de ventas expuesto internamente mediante ClusterIP.
- `backend-despachos`: microservicio de despachos expuesto internamente mediante ClusterIP.
- `mysql`: base de datos interna del cluster.

El usuario accede por el DNS publico del Load Balancer. El frontend consume los servicios backend mediante rutas internas de Kubernetes y los backends se conectan a MySQL dentro del cluster.

## Infraestructura AWS

Terraform define los siguientes recursos principales:

- VPC `eks-vpc`.
- Dos subredes publicas en `us-east-1a` y `us-east-1b`.
- Internet Gateway y Route Table para salida publica.
- Security Group con trafico HTTP por el puerto 80.
- Cluster EKS `innovatech-spa`.
- Node Group `workers` con instancias `t3.medium`.
- Repositorios ECR:
  - `innovatech-spa-frontend`
  - `innovatech-spa-backend`

## Kubernetes

Los manifiestos se encuentran en:

```text
infra/k8s/
```

Incluyen:

- Deployments de frontend, backend-ventas, backend-despachos y MySQL.
- Services para exponer y comunicar los pods.
- HPA para autoscaling de los microservicios backend.
- Secret para credenciales de base de datos.

## Variables de entorno y secretos

El proyecto usa GitHub Secrets para las credenciales de AWS:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

En Kubernetes se usa un Secret para las credenciales de MySQL:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
stringData:
  DB_USER: root
  DB_PASSWORD: root
```

Los backends leen estas credenciales mediante:

- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

MySQL lee la contrasena desde:

- `MYSQL_ROOT_PASSWORD`

## CI/CD

El pipeline esta dividido en dos workflows:

- `.github/workflows/ci.yml`
  - Construye la imagen Docker del frontend.
  - Construye las imagenes Docker de los backends.
  - Publica las imagenes en Amazon ECR.

- `.github/workflows/cd.yml`
  - Se ejecuta cuando el CI termina correctamente.
  - Configura credenciales AWS.
  - Configura `kubectl` contra EKS.
  - Actualiza los manifiestos con las imagenes publicadas en ECR.
  - Aplica los manifiestos Kubernetes con `kubectl apply`.
  - Valida el rollout de frontend y backends.

Flujo general:

```text
Commit + Push -> GitHub Actions CI -> Build Docker -> Push a ECR -> GitHub Actions CD -> Deploy a EKS
```

## Autoscaling

Se configura HPA para los microservicios backend:

- `backend-ventas`: minimo 1 replica, maximo 3 replicas, objetivo CPU 60%.
- `backend-despachos`: minimo 1 replica, maximo 3 replicas, objetivo CPU 60%.

Esto permite que Kubernetes aumente o reduzca la cantidad de pods segun la carga de CPU.

## Ejecucion local

Para levantar el entorno local con Docker Compose:

```bash
docker-compose up --build
```

## Despliegue de infraestructura

Desde la carpeta `infra`:

```bash
terraform init
terraform plan
terraform apply
```

Despues de crear la infraestructura, el despliegue de la aplicacion se realiza automaticamente mediante GitHub Actions al hacer push a la rama configurada.

## Comandos de evidencia

Comandos utiles para verificar el despliegue:

```bash
kubectl get nodes
kubectl get pods
kubectl get svc frontend
kubectl get endpoints frontend backend-ventas backend-despachos mysql
kubectl get hpa
kubectl logs deployment/backend-ventas --tail=30
kubectl logs deployment/backend-despachos --tail=30
```

Pruebas de API:

```bash
curl http://DNS_PUBLICO/api/ventas
curl http://DNS_PUBLICO/api/despachos
```

## Observabilidad

Para evidenciar observabilidad se pueden mostrar:

- logs del pipeline en GitHub Actions.
- logs de pods con `kubectl logs`.
- estado de pods, endpoints y HPA.
- recursos activos en la consola de AWS.

Una mejora productiva seria integrar CloudWatch Container Insights o Fluent Bit para centralizar logs y metricas del cluster EKS.

## Seguridad basica

El proyecto considera:

- GitHub Secrets para credenciales AWS.
- Kubernetes Secret para credenciales de MySQL.
- Security Group con puerto HTTP 80 expuesto.
- Repositorios ECR con escaneo de imagenes activado mediante Terraform.
- Dockerfiles multietapa para construir imagenes de frontend y backends.
- Archivos `.dockerignore` para evitar copiar contenido innecesario a las imagenes.

## Notas

El proyecto usa subredes publicas para simplificar el despliegue en el contexto academico. En un entorno productivo se recomienda usar subredes privadas para nodos y base de datos, exponiendo publicamente solo el Load Balancer.
