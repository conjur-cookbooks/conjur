KEYPAIR_NAME = test-kitchen
STACK_NAME = test-kitchen

apply: update-kitchen store-secrets

.PHONY: destroy apply apply-confirm store-secrets update-kitchen clean

key.pem:
	umask 066; openssl genrsa -out $@ 4096

key.imported: key.pem
	aws ec2 import-key-pair --key-name $(KEYPAIR_NAME) --public-key-material "`ssh-keygen -y -f $<`" | tee $@

stack.creating: cloudformation.yml key.imported
	aws cloudformation \
	  `[ -f stack.created ] && echo update-stack || echo create-stack` \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_IAM \
		--parameters ParameterKey=KeyPair,ParameterValue=$(KEYPAIR_NAME) \
		--tags Key=Name,Value=test-kitchen \
		--template-body "`cat $<`" > stack.status
	@mv stack.status $@

stack.created: stack.creating
	@echo Waiting for the stack to be created...
	@until aws cloudformation describe-stacks --stack-name $(STACK_NAME) | \
		tee stack.status | jq -r '.Stacks[0].StackStatus' | grep _COMPLETE; do \
		cat stack.status | jq -r '.Stacks[0].StackStatus';\
		sleep 10;\
	done
	@mv stack.status $@
	@echo "Stack created. Make sure to commit $@"

access.key: stack.created
	umask 066; aws iam create-access-key --user-name \
		`cat $< | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "UserName").OutputValue'` \
		> $@

destroy:
	aws cloudformation delete-stack --stack-name $(STACK_NAME)
	rm -f stack.created stack.creating access.key
	aws ec2 delete-key-pair --key-name $(KEYPAIR_NAME)
	rm -f key.imported

store-secrets: VAR_PREFIX = dev/aws
store-secrets: apply-confirm key.pem access.key policy.yml
	@echo "Applying policy and variable values."
	conjur policy load policy.yml
	cat access.key | jq -r '.AccessKey.AccessKeyId' | conjur variable values add $(VAR_PREFIX)/iam/users/test-kitchen/access_key_id
	cat access.key | jq -r '.AccessKey.SecretAccessKey' | conjur variable values add $(VAR_PREFIX)/iam/users/test-kitchen/secret_access_key
	cat key.pem | conjur variable values add $(VAR_PREFIX)/ec2/ssh-keys/test-kitchen
	@echo "Secrets stored. You may now run 'make clean' to remove the local copy."

clean:
	rm -f access.key key.pem

apply-confirm:
ifndef CONFIRM
	@echo "Please examine the policy and the 'store-secrets' Makefile step before executing."
	@echo "In particular, make sure VAR_PREFIX matches policy.yml and secrets.yml,"
	@echo "and that you're not missing --as-group or similar parameter to 'conjur policy load'."
	@echo "Then start make with 'make apply CONFIRM=yes'."
	@false
endif

update-kitchen: REGION = $(shell cat stack.created | jq -r '.Stacks[0].StackId | split(":")[3]')
update-kitchen: SUBNET = $(shell cat stack.created | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "SubnetId").OutputValue')
update-kitchen: SG = $(shell cat stack.created | jq -r '.Stacks[0].Outputs[] | select(.OutputKey == "SecurityGroupId").OutputValue')
update-kitchen: stack.created
	@sed -i "\
		s/\(^\s\+region\):.*/\1: $(REGION)/;\
		s/\(^\s\+subnet_id\):.*/\1: $(SUBNET)/;\
		s/\(^\s\+aws_ssh_key_id\):.*/\1: $(KEYPAIR_NAME)/;\
		s/\(^\s\+security_group_ids\):.*/\1: [$(SG)]/;\
	" ../../.kitchen.yml
	@echo "../../kitchen.yml updated. Make sure to commit it."
