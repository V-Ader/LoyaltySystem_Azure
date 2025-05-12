# Loyalty - Azure

# Deployment

### create infrastructure
```bash
cd terraform
terraform init
terraform apply
```

### setup db
```bash
cd scripts
./setup_db.sh
```

### publish functions
```bash
cd app
./publish_functions.sh
```