.PHONY: init validate plan apply test lint build-layer clean

# Terraform commands
init:
	terraform init

validate:
	terraform validate

plan:
	terraform plan

apply:
	terraform apply

# Lambda layer build
build-layer:
	cd modules/quicksuite-analytics/lambda/dependencies_layer && \
	docker build --platform linux/arm64 -t quicksuite-dependencies-layer . && \
	container_id=$$(docker create quicksuite-dependencies-layer) && \
	rm -rf python layer.zip && \
	docker cp $$container_id:/opt/python ./python && \
	docker rm $$container_id && \
	zip -r layer.zip python -q && \
	rm -rf python

# Tests
test:
	python3 -m pytest test/unit -v

# Security scanning with Checkov
lint:
	checkov -d modules/quicksuite-analytics/ --framework terraform --quiet

# Full check (what CI would run)
check: validate test lint

clean:
	rm -rf .terraform .terraform.lock.hcl
	rm -f modules/quicksuite-analytics/lambda/*.zip
	rm -f modules/quicksuite-analytics/lambda/dependencies_layer/layer.zip
	rm -rf modules/quicksuite-analytics/lambda/dependencies_layer/python
