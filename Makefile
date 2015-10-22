PROJECT = viewcounter
FUNCTION?= $(PROJECT)
REGION = us-east-1
PAYLOAD?='{"key1":"value1", "key2":"value2", "key3":"value3"}'
ROLE=$(shell aws iam get-role --role-name $(PROJECT) --query 'Role.Arn' | tr -d '"')
all: build
build: clean
	mkdir -p build
	pip install -t build/ .
	pip install -t build/ -r requirements.txt 
	cp .env build/
	cd build; zip -r ../$(FUNCTION).zip .; cd ..
clean:
	rm -rf build/
	rm *.zip
destroy:
	aws lambda delete-function --function-name $(FUNCTION)
deploy: build
	aws lambda create-function \
    --region $(REGION) \
    --function-name $(FUNCTION) \
    --zip-file fileb://$(FUNCTION).zip \
    --role $(ROLE) \
    --handler "$(PROJECT)"_lambda.handler \
    --runtime python2.7 \
    --timeout 15 \
    --memory-size 128
create_role:
	aws iam create-role --role-name $(PROJECT) --assume-role-policy-document file://role_trust.json
	aws iam put-role-policy --role-name $(PROJECT) --policy-name $(PROJECT)-permissions --policy-document file://role_permissions.json
update_role:
	aws iam put-role-policy --role-name $(PROJECT) --policy-name $(PROJECT)-permissions --policy-document file://role_permissions.json
delete_role:
	aws iam delete-role-policy --role-name $(PROJECT) --policy-name $(PROJECT)-permissions
	aws iam delete-role --role-name $(PROJECT)
create_resources:
	aws dynamodb create-table --table-name $(PROJECT) --attribute-definitions AttributeName=counter_name,AttributeType=S --key-schema AttributeName=counter_name,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
destroy_resources:
	aws dynamodb delete-table $(PROJECT)
invoke:
	aws lambda invoke \
    --invocation-type RequestResponse \
    --function-name $(FUNCTION) \
    --region $(REGION) \
    --log-type Tail \
    --payload $(PAYLOAD) outputfile.txt --query 'LogResult' | tr -d '"' | base64 --decode
